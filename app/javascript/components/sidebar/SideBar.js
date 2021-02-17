import React, { useContext } from 'react';
import { Link as RouterLink, useLocation } from 'react-router-dom';
import PropTypes from 'prop-types';
import {
  Avatar,
  Box,
  Button,
  Divider,
  Drawer,
  Hidden,
  List,
  Typography,
  makeStyles
} from '@material-ui/core';
import DashboardIcon from '@material-ui/icons/Dashboard';
import BackupIcon from '@material-ui/icons/Backup';
import NavItem from './SideItem';

import { MainContext } from '@/contexts/MainContext';

const items = [
  {
    href: '/dashboard',
    icon: DashboardIcon,
    title: 'Dashboard'
  },
  {
    href: '/import',
    icon: BackupIcon,
    title: 'Import'
  }
];

const useStyles = makeStyles(() => ({
  desktopDrawer: {
    width: 256,
    top: 64,
    height: 'calc(100% - 64px)'
  },
  avatar: {
    cursor: 'pointer',
    width: 64,
    height: 64
  }
}));

const NavBar = () => {
  const classes = useStyles();
  const location = useLocation();
  const { currentUser } = useContext(MainContext);

  const content = (
    <Box
      height="100%"
      display="flex"
      flexDirection="column"
    >
      <Box
        alignItems="center"
        display="flex"
        flexDirection="column"
        p={2}
      >
        <Avatar
          className={classes.avatar}
          component={RouterLink}
          src={currentUser.avatar_image}
          to="/app/account"
        />
        <Typography
          className={classes.name}
          color="textPrimary"
          variant="h5"
        >
          {currentUser.full_name}
        </Typography>
        <Typography
          color="textSecondary"
          variant="body2"
        >
          {currentUser.email}
        </Typography>
      </Box>
      <Divider />
      <Box p={2}>
        <List>
          {items.map((item) => (
            <NavItem
              href={item.href}
              key={item.title}
              title={item.title}
              icon={item.icon}
            />
          ))}
        </List>
      </Box>
    </Box>
  );

  return (
    <>
      <Hidden mdDown>
        <Drawer
          anchor="left"
          classes={{ paper: classes.desktopDrawer }}
          open
          variant="persistent"
        >
          {content}
        </Drawer>
      </Hidden>
    </>
  );
};

export default NavBar;
