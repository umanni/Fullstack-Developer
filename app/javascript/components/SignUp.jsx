import React, { useCallback } from 'react';
import { Link } from 'react-router-dom';
import { Container, Button, TextField } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';

import Api from '../services/api';

const useStyles = makeStyles(theme => ({
  root: {
    '& .MuiTextField-root': {
      margin: theme.spacing(1),
      width: '100%',
    },
    '& .MuiButton-root': {
      margin: theme.spacing(1),
    },
  },
}));

export default () => {
  const classes = useStyles();

  const handleSubmit = useCallback(async event => {
    event.preventDefault();

    const {
      fullName,
      email,
      password,
      repeatPassword,
      avatarImage,
    } = event.target;
  }, []);

  return (
    <Container maxWidth="sm">
      <h1 className="display-4 text-center">Sign Up</h1>
      <form className={classes.root} onSubmit={handleSubmit}>
        <TextField
          id="fullName"
          variant="outlined"
          label="Insert your full name"
        />
        <TextField id="email" variant="outlined" label="Insert your email" />
        <TextField
          id="password"
          variant="outlined"
          label="Insert your password"
          type="password"
        />
        <TextField
          id="repeatPassword"
          variant="outlined"
          label="Repeat your password"
          type="password"
        />
        <TextField
          id="avatarImage"
          variant="outlined"
          label="Your avatar url"
        />
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
