import React, { useCallback, useState } from 'react';
import { Link, useHistory } from 'react-router-dom';
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
  const [user, setUser] = useState(null);
  const history = useHistory();

  const handleSubmit = useCallback(
    async event => {
      event.preventDefault();

      const { email, password } = event.target;

      await Api.post('users/sign_in', {
        user: {
          email: email.value,
          password: password.value,
        },
      }).then(response => {
        setUser(response.data);

        if (user) {
          history.push('/profile');
        }
      });
    },
    [user],
  );

  return (
    <Container maxWidth="sm">
      <h1 className="display-4 text-center">Sign In</h1>
      <form className={classes.root} onSubmit={handleSubmit}>
        <TextField id="email" variant="outlined" label="Email" />
        <TextField
          id="password"
          variant="outlined"
          label="Password"
          type="password"
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
