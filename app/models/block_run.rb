# frozen_string_literal: true

require "json"

class BlockRun < ApplicationRecord
  INPUT_SCHEMA_NOT_SATISFIED = "input_schema_not_satisfied"

  belongs_to :block
  has_one :user, through: :block

  ENVIRONMENT_COMMANDS = {
    "node" => "node",
    "ruby" => "ruby",
    "python2" => "python",
  }.freeze

  def execute
    if schema_satisfied?
      container.start

      workdir = "/flow"
      container.store_file("#{workdir}/input.json", args)
      container.store_file("#{workdir}/user_script", block.body)

      command = [
        ENVIRONMENT_COMMANDS[block.environment],
        "#{workdir}/user_script",
      ].join(" ")

      output, errors, self.exit_status = container.exec(
        ["/bin/sh", "-c", "cd #{workdir} && #{command}"]
      )

      container.stop
      container.delete

      self.output = output.join
      self.run_errors = errors.join

      save!
    else
      update!(status: BlockRun::INPUT_SCHEMA_NOT_SATISFIED)
    end
  end

  def exit_status=(value)
    super(value)

    if value == 0
      self.status = :success
    elsif value
      self.status = :failure
    end
  end

  private

  def container
    @container ||= Docker::Container.create(
      "Image" => block.environment,
      "Tty" => true,
    )
  end

  def schema_satisfied?
    schema = JSON.parse(block.schema)
    JSON::Validator.validate(schema, args)
  end
end
