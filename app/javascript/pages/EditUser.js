/* eslint-disable camelcase */
import React, { useCallback, useEffect, useState } from 'react';
import { Link, useRouteMatch } from 'react-router-dom';
import { Container, Button, TextField, makeStyles } from '@material-ui/core';

import TopBar from '@/components/TopBar';

import Api from '@/services/api';

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
      Api.get(`/api/users/${id}`).then(response => {
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
      console.log('aqui');

      const { id } = params;
      const {
        full_name,
        email,
        avatar_image,
        admin,
      } = event.target;

      Api.put(`/api/users/${id}`, {
        user: {
          full_name: full_name.value,
          email: email.value,
          avatar_image: avatar_image.value,
          admin: false,
        },
      });
    },
    [params],
  );

  return (
    <>
      <TopBar />
      <Container maxWidth="sm">
        <h1 className="display-4 text-center">Edit {user && user.full_name} profile</h1>
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
            id="avatar_image"
            variant="outlined"
            label="Your avatar url"
            value={inputState.avatar_image}
            onChange={inputChange}
          />
          <hr className="my-4" />
          <Button type="submit" variant="contained" color="secondary">
            Update user
          </Button>
          <Link to="/" role="button">
            <Button variant="contained" color="primary">
              Home
            </Button>
          </Link>
        </form>
      </Container>
    </>
  );
};
