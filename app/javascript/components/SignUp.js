/* eslint-disable camelcase */
import React from 'react';
import { csrfToken } from 'rails-ujs'
import { Container, Button, TextField, makeStyles } from '@material-ui/core';

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

  return (
    <Container maxWidth="sm">
      <h1 className="display-4 text-center">Sign Up</h1>
      <form action="/users" method="post" className={classes.root}>
        <input type="hidden" name="authenticity_token" value={csrfToken()}/>
        <input type="hidden" name="user[admin]" value={false}/>
        <TextField
          name="user[full_name]"
          variant="outlined"
          label="Insert your full name"
        />
        <TextField
          name="user[email]"
          variant="outlined"
          label="Insert your email"
        />
        <TextField
          name="user[password]"
          variant="outlined"
          label="Insert your password"
          type="password"
        />
        <TextField
          name="user[password_confirmation]"
          variant="outlined"
          label="Repeat your password"
          type="password"
        />
        <TextField
          name="user[avatar_image]"
          variant="outlined"
          label="Your avatar url"
        />
        <hr className="my-4" />
        <Button type="submit" variant="contained" color="secondary">
          Sign Up
        </Button>
      </form>
    </Container>
  );
};
