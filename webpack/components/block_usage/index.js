import React from "react"
import PropTypes from "prop-types"
import $ from "jquery"

import Form from "react-jsonschema-form"
import RunStatus from "components/run_status"
import CodeUsage from "./code_usage"

import EditableField from "components/editable_field"

import Section from "components/section"
import Hint from "components/hint"

import updateBlock from "util/update_block"

class BlockUsage extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      inputData: this.props.initial_input_data || {},
      run: null,

      schema: this.props.schema
    }
  }

  render() {
    const uiSchema =  {
      ssh_private_key: {
        "ui:widget": "textarea" // could also be "select"
      }
    };

    return (
      <Section>
        { this.renderRun() }

        <h2>Try it out</h2>

        <Hint>
          Run this block with custom inputs,
          in a web form or on your command line.
        </Hint>

        <EditableField.Schema
          editable={this.props.user.id == this.props.current_user.id}
          initialValue={this.state.schema}
          onChange={this.schemaUpdated.bind(this)}
          >

          <Form
            uiSchema={uiSchema}
            schema={this.state.schema}
            onChange={ (e) => this.setState({ inputData: e.formData }) }
            onSubmit={this.onSubmit.bind(this)}
            formData={this.state.inputData}
            >
            <div style={{ position: "relative", overflow: "hidden" }}>
              <a onClick={() => this.setState({ inputData: {} }) }>
                Clear input fields
              </a>

              <button
                type="submit"
                style={{ float: "right" }}
                disabled={this.props.user_api_key == null}
              >
              Go
              </button>
            </div>
          </Form>
        </EditableField.Schema>

        <CodeUsage
          user_api_key={this.props.user_api_key}
          input_data={this.state.inputData}
          run_block_url={this.props.run_block_url}
          />
      </Section>
    );
  }

  onSubmit(event) {
    this.setState({ run: { status: "pending" } });

    $.post(
      this.props.run_block_url,
      { data: event.formData },
      this.runFinished.bind(this),
    )
  }

  runFinished(event) {
    this.setState({ run: event })
  }

  renderRun() {
    if(this.state.run)
      return <RunStatus {...this.state.run}/>
  }

  schemaUpdated(newSchema) {
    this.setState({schema: newSchema})

    updateBlock(
      { schema_json: JSON.stringify(newSchema) },
      this.props.user.handle,
      this.props.name,
    )
  }
}

BlockUsage.propTypes = {
  user_api_key: PropTypes.string.isRequired,
  run_block_url: PropTypes.string.isRequired,
  user: PropTypes.object.isRequired,
  name: PropTypes.string.isRequired,
  schema: PropTypes.object.isRequired,
  initial_input_data: PropTypes.object,
}

export default BlockUsage;
