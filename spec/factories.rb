# frozen_string_literal: true

FactoryGirl.define do
  factory :block, aliases: [:destination] do
    user
    sequence(:name) { |n| "block_#{n}" }

    command "ruby /app/script.rb"
    dockerfile "FROM ruby\n"
    source "puts 'Hello, World!'\n"
    source_path "/app/script.rb"
  end

  factory :block_run do
    block
    input({ message: "Hello, World!" })
    output({ result: "Hello, World!" })
    status :success
    stderr ""
    stdout ""
  end

  factory :event do
    data({})
    trigger
  end

  factory :service do
    name "GitHub"
    domain "github.com"
  end

  factory :subscription do
    block
    user
    trigger
    data_overrides {}
  end

  factory :trigger do
    name "Push"
    description "New commits pushed to the GitHub repository"
    service

    default_options(
      "repo" => "assembleapp/registry"
    )

    options_schema(
      type: :object,
      properties: {
        repo: { type: :string },
      },
      required: [:repo]
    )
  end

  factory :user do
    sequence(:handle) { |n| "user_#{n}" }
    sequence(:github_uid) { |n| n }
    sequence(:github_token) { |n| n }
  end
end
