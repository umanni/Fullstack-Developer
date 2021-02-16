import React, { useContext } from 'react';
import { Link } from 'react-router-dom';
import clsx from 'clsx';
import PropTypes from 'prop-types';
import {
  AppBar,
  Box,
  IconButton,
  Toolbar,
  makeStyles,
  Avatar
} from '@material-ui/core';
import HomeIcon from '@material-ui/icons/Home';
import InputIcon from '@material-ui/icons/Input';

import { MainContext } from '@/contexts/MainContext';

const useStyles = makeStyles(() => ({
  root: {},
  avatar: {
    width: 60,
    height: 60
  }
}));

const TopBar = ({
  className,
  onMobileNavOpen,
  ...rest
}) => {
  const classes = useStyles();
  const { currentUser } = useContext(MainContext);

  return (
    <AppBar
      className={clsx(classes.root, className)}
      elevation={0}
      {...rest}
    >
      <Toolbar>
        <Link to="/">
          <HomeIcon fontSize="large" style={{color: 'white'}}/>
        </Link>
        <Box flexGrow={1} />
        <Link to="/profile">
          <Avatar alt={currentUser.full_name} src={currentUser.avatar_image}></Avatar>
        </Link>
        <Link to="/users/sign_out" data-method="delete">
          <IconButton style={{color: 'white'}}>
            <InputIcon />
          </IconButton>
        </Link>
      </Toolbar>
    </AppBar>
  );
};

TopBar.propTypes = {
  className: PropTypes.string,
  onMobileNavOpen: PropTypes.func
};

export default TopBar;
