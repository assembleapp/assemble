import React from "react"
import styled from "styled-components"
import { graphql, compose } from "react-apollo"

import Section from "components/section"
import Link from "components/link"

import create_block from "graphql/create_block.gql"

class WelcomeMessage extends React.Component {
  render() {
    return (
      <Row>
        <Wrapper>
          <p>
          Assemble is a registry of open-source, publicly-usable&nbsp;
          <Link external to="https://www.notion.so/assemble/Glossary-107d90a48c6441f79ff35b6943cc3fad#44c9a85610884b45a1f8941e4f9d9f9c">
          Serverless functions
          </Link>,
          which we call <em>Blocks</em>.
          </p>

          <p>
          We are working with the community to make it easier to use and share blocks,
          with the goal of making them as accessible as possible
          for novice developers and non-developers.&nbsp;
          <Link to="/about">Learn more</Link>.
          </p>

          <p>
          { this.props.session
            ? <button onClick={this.createNewBlock.bind(this)}>+ Create a new block</button>
            : <Link external to="/session/new">Sign in to get started</Link>
          }
          </p>
        </Wrapper>
      </Row>
    );
  }

  createNewBlock() {
    this.props.create_block().then(({ data }) => {
      window.location = `/blocks/${data.create_block.id}`
    })
  }
}

const Row = styled.div`
  display: flex;
  justify-content: space-around;
`

const Wrapper = styled(Section)`
  width: 50%;
`

export default compose(
  graphql(create_block, { name: "create_block" }),
)(WelcomeMessage);
