import React from 'react';
import { Link } from 'react-router-dom';
import { Container, Button } from '@material-ui/core';

export default () => (
  <Container maxWidth="sm">
    <h1 className="display-4">Home</h1>
    <hr className="my-4" />
    <Link to="/sign_in" role="button">
      <Button variant="contained" color="primary">
        Sign In
      </Button>
    </Link>
    <Link to="/sign_up" role="button">
      <Button variant="contained" color="secondary">
        Sign Up
      </Button>
    </Link>
  </Container>
);
