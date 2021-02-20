import React, { useState, useCallback } from 'react';
import { useHistory } from 'react-router-dom'
import {
  Container,
  Button,
  TextField,
  makeStyles,
  Box,
  FormControlLabel,
  Switch
} from '@material-ui/core';
import * as Yup from 'yup';

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
  const [formError, setFormError] = useState({
    full_name: '',
    email: '',
    password: '',
    password_confirmation: '',
    avatar_url: '',
    admin: false,
  })
  const {addToast} = useToast();
  const history = useHistory();

  const handleSubmit = useCallback(
    async event => {
      event.preventDefault();

      const {
        full_name,
        email,
        password,
        password_confirmation,
        avatar_image,
        admin,
      } = event.target;

      try {
        const schema = Yup.object().shape({
          full_name: Yup.string().required('The full name field is required'),
          email: Yup.string().required('The email field is required'),
          password: Yup.string().required('The password field is required'),
          password_confirmation: Yup.string().required('You must confirm the password'),
          avatar_image: Yup.string().required('Insert the user avatar image url'),
        });

        await schema.validate({
          full_name: full_name.value,
          email: email.value,
          password: password.value,
          password_confirmation: password_confirmation.value,
          avatar_image: avatar_image.value,
        }, {abortEarly: false});

        Api.post('/api/users', {
          user: {
            full_name: full_name.value,
            email: email.value,
            password: password.value,
            password_confirmation: password_confirmation.value,
            avatar_image: avatar_image.value,
            admin: admin.checked,
          },
        }).then(() => {
          addToast({
            type: 'success',
            title: 'Success!',
            description:
              'User created successfully!',
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
    [],
  );

  return (
    <>
      <TopBar />
      <SideBar />

      <Container maxWidth="sm" style={{marginTop: 72}}>
        <form className={classes.root} onSubmit={handleSubmit}>
          <TextField
            id="full_name"
            error={!!formError.full_name}
            helperText={formError.full_name}
            variant="outlined"
            label="Full name"
          />
          <TextField
            id="email"
            error={!!formError.email}
            helperText={formError.email}
            variant="outlined"
            label="Email"
          />
          <TextField
            id="password"
            error={!!formError.password}
            helperText={formError.password}
            variant="outlined"
            type="password"
            label="Password"
          />
          <TextField
            id="password_confirmation"
            error={!!formError.password_confirmation}
            helperText={formError.password_confirmation}
            variant="outlined"
            type="password"
            label="Password confirmation"
          />
          <TextField
            id="avatar_image"
            error={!!formError.avatar_image}
            helperText={formError.avatar_image}
            variant="outlined"
            label="Avatar image url"
          />
          <Box flexGrow={1} left="57%" position="absolute">
            <FormControlLabel
              control={
                <Switch
                  id="admin"
                  color="primary"
                />
              }
              label="Administrator"
            />
          </Box>
          <br/><br/><br/>
          <hr className="my-4" />
          <Button type="submit" variant="contained" color="primary">
            Create user
          </Button>
        </form>
      </Container>
    </>
  );
};
