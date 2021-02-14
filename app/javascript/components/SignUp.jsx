/* eslint-disable camelcase */
import React, { useCallback } from 'react';
import { Link } from 'react-router-dom';
import { Container, Button, TextField, makeStyles } from '@material-ui/core';

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
      full_name,
      email,
      password,
      password_confirmation,
      avatar_image,
    } = event.target;

    Api.post('users', {
      user: {
        full_name: full_name.value,
        email: email.value,
        password: password.value,
        password_confirmation: password_confirmation.value,
        avatar_image: avatar_image.value,
        admin: false,
      },
    }).then(response => {
      console.log(response);
    });
  }, []);

  return (
    <Container maxWidth="sm">
      <h1 className="display-4 text-center">Sign Up</h1>
      <form className={classes.root} onSubmit={handleSubmit}>
        <TextField
          id="full_name"
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
          id="password_confirmation"
          variant="outlined"
          label="Repeat your password"
          type="password"
        />
        <TextField
          id="avatar_image"
          variant="outlined"
          label="Your avatar url"
        />
        <hr className="my-4" />
        <Button type="submit" variant="contained" color="secondary">
          Sign Up
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
