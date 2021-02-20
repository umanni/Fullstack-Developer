/* eslint-disable camelcase */
import React, {
  useCallback,
  useEffect,
  useState,
  useContext,
} from 'react';
import { useRouteMatch, useHistory } from 'react-router-dom';
import {
  Container,
  Button,
  TextField,
  makeStyles,
  FormControlLabel,
  Switch,
  Box,
} from '@material-ui/core';
import * as Yup from 'yup';

import { MainContext, setMyPosition } from '@/contexts/MainContext';
import { useToast } from '@/hooks/Toast';
import getValidationErrors from '@/utils/getValidationErrors';

import TopBar from '@/components/TopBar';
import SideBar from '@/components/sidebar/SideBar';

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
  const { currentUser, updateValue, setMyPosition } = useContext(MainContext);
  const { params } = useRouteMatch();
  const [user, setUser] = useState({});
  const [inputState, setInputState] = useState({
    full_name: '',
    email: '',
    avatar_image: '',
    admin: false,
  });
  const [formError, setFormError] = useState({
    full_name: '',
    email: '',
    avatar_image: '',
  })
  const {addToast} = useToast();
  const history = useHistory();

  useEffect(() => {
    setMyPosition('Edit user');
  }, []);

  useEffect(() => {
    const { id } = params;

    if (id) {
      Api.get(`/api/users/${id}`).then(response => {
        setUser(response.data);
      });
    }
  }, [params]);

  useEffect(() => {
    setInputState({
      full_name: user.full_name,
      email: user.email,
      avatar_image: user.avatar_image,
      admin: user.admin,
    });
  }, [user]);

  const inputChange = useCallback(
    event => {
      setInputState({ ...inputState, [event.target.id]: event.target.value });
    },
    [inputState],
  );

  const switchChange = useCallback(
    event => {
      setInputState({ ...inputState, [event.target.id]: event.target.checked });
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
        avatar_image,
        admin,
      } = event.target;

      try {
        const schema = Yup.object().shape({
          full_name: Yup.string().required('The full name is required'),
          email: Yup.string().required('Email required').email('Insert a valid email'),
          avatar_image: Yup.string().required('Insert the image URL path'),
        })

        await schema.validate({
          full_name: full_name.value,
          email: email.value,
          avatar_image: avatar_image.value
        }, {abortEarly: false});

        Api.put(`/api/users/${id}`, {
          user: {
            full_name: full_name.value,
            email: email.value,
            avatar_image: avatar_image.value,
            admin: admin.checked,
          },
        }).then(response => {
          const {id, full_name, email, avatar_image, admin} = response.data;

          if (currentUser.id == id) {
            updateValue({
              id,
              full_name,
              email,
              avatar_image,
              admin
            });
          }
          addToast({
            type: 'success',
            title: 'Success!',
            description:
              'User updated successfuly!',
          });

          history.push('/');
        });
      } catch(error) {
        if (error instanceof Yup.ValidationError) {
          const serializedErrors = getValidationErrors(error);
          setFormError(serializedErrors);

          return;
        }
      }
    },
    [params],
  );

  const handleSelfDelete = useCallback(() => {
    Api.delete(`/api/users/${currentUser.id}`)
    .then(() => {
      location.reload();
    });
  }, []);

  return (
    <>
      <TopBar />
      {currentUser.admin && <SideBar />}
      <Container maxWidth="sm" style={{marginTop: '72px'}}>
        <form className={classes.root} onSubmit={handleSubmit}>
          <TextField
            id="full_name"
            error={!!formError.full_name}
            helperText={formError.full_name}
            variant="outlined"
            label="Full name"
            value={inputState.full_name ? inputState.full_name : ''}
            onChange={inputChange}
          />
          <TextField
            id="email"
            error={!!formError.email}
            helperText={formError.email}
            variant="outlined"
            label="Email"
            value={inputState.email ? inputState.email : ''}
            onChange={inputChange}
          />
          <TextField
            id="avatar_image"
            error={!!formError.avatar_image}
            helperText={formError.avatar_image}
            variant="outlined"
            label="Avatar url"
            value={inputState.avatar_image ? inputState.avatar_image : ''}
            onChange={inputChange}
          />
          {currentUser.admin
            ? (
              <Box flexGrow={1} left="57%" position="absolute">
                <FormControlLabel
                  control={
                    <Switch
                      checked={inputState.admin ? inputState.admin : false}
                      onChange={switchChange}
                      id="admin"
                      color="primary"
                    />
                  }
                  label="Administrator"
                />
              </Box>
            )
            : (<input type="hidden" id="admin" value="false" />)
          }
          <br/><br/><br/>
          <hr className="my-4" />
          <Button type="submit" variant="contained" color="primary">
            Update user
          </Button>
          <Button variant="contained" color="secondary" onClick={handleSelfDelete}>
            Delete Account
          </Button>
        </form>
      </Container>
    </>
  );
};
