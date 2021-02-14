import React, { useCallback } from 'react';
import { Link } from 'react-router-dom';
import { Container, Button, TextField } from '@material-ui/core';

export default () => {
  const handleSubmit = useCallback(async event => {
    event.preventDefault();
    console.log('aqui');
  }, []);

  return (
    <Container maxWidth="sm">
      <h1 className="display-4 text-center">Sign In</h1>
      <form onSubmit={handleSubmit}>
        <TextField id="" variant="outlined" label="Email" />
        <br />
        <br />
        <TextField id="" variant="outlined" label="Password" type="password" />
        <hr className="my-4" />
        <Button type="submit" variant="contained" color="secondary">
          Login
        </Button>
        <Link to="/" role="button">
          <Button variant="contained" color="primary">
            Home
          </Button>
        </Link>
      </form>
    </Container>
  );
};
