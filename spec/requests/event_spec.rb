# frozen_string_literal: true

require "rails_helper"

describe "POST block_runs#create" do
  it "exposes any set environment variables to the script" do
    skip "Environment variables should be renamed to `Configuration variables`,
    and should be associated with apps, not programs.
    They should potentially have a `public` option,
    so that they can be copied over with an app if they're not sensitive."

    block = create(:block, body: <<-JS)
      flow = require('./flow.js')
      console.log(flow.env.foo)
    JS
    create(:env_variable, block: block, key: "foo", value: "bar")

    expect do
      post(
        "/blocks/#{block.user.username}/#{block.name}/runs",
        params: { foo: "bar" },
      )
    end.to change(BlockRun, :count).by(1)

    expect(response.body).to eq("Block run has been queued.")
    expect(BlockRun.last.output).to eq("bar\n")
  end
end

describe "POST events#create" do
  it "runs subscribed blocks with the provided input" do
    message = "this is a sample message"
    feed = create(:feed, schema: "{}")

    block = create(:block, environment: "ruby", body: <<-SCRIPT)
      require "json"
      input = JSON.parse(File.read("input.json"))
      puts input["message"]
    SCRIPT

    create(:connection, source: feed, destination: block)
    params = { event: { message: message }, format: 'text' }

    expect do
      post "/events/#{feed.name}", params: params
    end.to change(BlockRun, :count).by(1)

    block_run = BlockRun.last
    expect(block_run.block).to eq(block)
    expect(block_run.output).to eq(message + "\n")
    expect(response.body).to eq t(
      "events.create.success",
      num_apps: '1 app',
      num_blocks: '1 block',
    )
  end

  it "rejects events that do not match the schema" do
    schema = <<-SCHEMA
      {
        "type": "object",
        "properties": { "foo": { "type": "integer" } }
      }
      SCHEMA

    block = create(:block, schema: schema)
    feed = create(:feed, schema: schema)
    create(:connection, source: feed, destination: block)

    params = { event: { foo: "bar" }, format: :text }
    post("/events/#{feed.name}", params: params)

    expect(response).to be_success
    expect(response.body).to eq t(
      "events.create.success",
      num_apps: '1 app',
      num_blocks: '1 block',
    )
    expect(BlockRun.last.status).to eq(BlockRun::INPUT_SCHEMA_NOT_SATISFIED)
  end

  it "only runs blocks when their schemas are fully satisfied by their connections"

  it "rejects events that are not properly authenticated"
  it "rejects events that are not authorized for the event stream"
end
