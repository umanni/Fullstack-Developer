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
      <h1 className="display-4 text-center">Sign In</h1>
      <form action="/users/sign_in" method="post" className={classes.root}>
        <input type="hidden" name="authenticity_token" value={csrfToken()}/>
        <TextField name="user[email]" variant="outlined" label="Email" />
        <TextField
          name="user[password]"
          variant="outlined"
          label="Password"
          type="password"
        />
        <hr className="my-4" />
        <Button type="submit" variant="contained" color="secondary">
          Login
        </Button>
      </form>
    </Container>
  );
};
