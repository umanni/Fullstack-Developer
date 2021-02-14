import React from 'react';
import { Link } from 'react-router-dom';
import { Container, Button, makeStyles } from '@material-ui/core';

const useStyles = makeStyles(theme => ({
  root: {
    '& .MuiButton-root': {
      margin: theme.spacing(1),
    },
  },
}));

export default () => {
  const classes = useStyles();

  return (
    <Container maxWidth="sm" className={classes.root}>
      <h1 className="display-4">Home</h1>
      <hr className="my-4" />
      <Link to="/sign_in" role="button">
        <Button variant="contained" color="primary">
          Sign In
        </Button>
      </Link>
      <Link to="/sign_up" role="button">
        <Button variant="contained" color="secondary">
          Sign Up
        </Button>
      </Link>
    </Container>
  );
};
