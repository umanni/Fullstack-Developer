import React from 'react';
import { Link } from 'react-router-dom';
import { Container, Button, TextField } from '@material-ui/core';

export default () => (
  <Container maxWidth="sm">
    <h1 className="display-4">Home</h1>
    <p className="lead">Home</p>
    <hr className="my-4" />
    <Link to="/sign_in" className="btn btn-lg custom-button" role="button">
      Sign in
    </Link>
  </Container>
);
