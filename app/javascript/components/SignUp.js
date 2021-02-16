/* eslint-disable camelcase */
import React, { useCallback, useEffect, useState, useMemo } from 'react';
import { Link, useHistory, useRouteMatch } from 'react-router-dom';
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
  const history = useHistory();
  const { params } = useRouteMatch();
  const [user, setUser] = useState(null);
  const [inputState, setInputState] = useState({
    full_name: '',
    email: '',
    avatar_image: '',
    role: false,
  });

  useEffect(() => {
    const { id } = params;

    if (id) {
      Api.get(`users/${id}`).then(response => {
        setUser(response.data);
      });
    }
  }, [params]);

  useEffect(() => {
    if (user) {
      setInputState({
        full_name: user.full_name,
        email: user.email,
        avatar_image: user.avatar_image,
        role: user.role,
      });
    }
  }, [user]);

  const link = useMemo(() => {
    if (user) {
      return `/profile/${user.id}`;
    }

    return '/';
  }, [user]);

  const passwordLabel = useMemo(() => {
    if (user) {
      return 'Leave in blank if you dont want to change the password';
    }

    return 'Insert your password';
  }, [user]);

  const inputChange = useCallback(
    event => {
      console.log(event.target.id, event.target.value);
      setInputState({ ...inputState, [event.target.id]: event.target.value });
    },
    [inputState],
  );

  const handleSubmit = useCallback(
    async event => {
      event.preventDefault();

      const { id } = params;
      const {
        full_name,
        email,
        password,
        password_confirmation,
        avatar_image,
        admin,
      } = event.target;

      if (!id) {
        Api.post('users', {
          user: {
            full_name: full_name.value,
            email: email.value,
            password: password.value,
            password_confirmation: password_confirmation.value,
            avatar_image: avatar_image.value,
            admin: false,
          },
        }).then(() => {
          history.push('/sign_in');
        });
      } else {
        Api.put(`users/${id}`, {
          user: {
            full_name: full_name.value,
            email: email.value,
            password: password.value ? password.value : undefined,
            password_confirmation: password_confirmation.value
              ? password_confirmation.value
              : undefined,
            avatar_image: avatar_image.value,
            admin: false,
          },
        });
      }
    },
    [history, params],
  );

  return (
    <Container maxWidth="sm">
      <h1 className="display-4 text-center">Sign Up</h1>
      <form className={classes.root} onSubmit={handleSubmit}>
        <TextField
          id="full_name"
          variant="outlined"
          label="Insert your full name"
          value={inputState.full_name}
          onChange={inputChange}
        />
        <TextField
          id="email"
          variant="outlined"
          label="Insert your email"
          value={inputState.email}
          onChange={inputChange}
        />
        <TextField
          id="password"
          variant="outlined"
          label={passwordLabel}
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
          value={inputState.avatar_image}
          onChange={inputChange}
        />
        <hr className="my-4" />
        <Button type="submit" variant="contained" color="secondary">
          {user ? 'Update' : 'Sign Up'}
        </Button>
        <Link to={link} role="button">
          <Button variant="contained" color="primary">
            Home
          </Button>
        </Link>
      </form>
    </Container>
  );
};
