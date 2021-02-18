import React, { useState, useEffect } from 'react';
import {
  Container,
  Grid,
  makeStyles,
  Box
} from '@material-ui/core';
import PeopleIcon from '@material-ui/icons/PeopleOutlined';
import WarningIcon from '@material-ui/icons/WarningOutlined';

import DashboardSimpleCard from '@/components/DashboardSimpleCard';
import UsersList from '@/components/users/UsersList';
import TopBar from '@/components/TopBar';
import SideBar from '@/components/sidebar/SideBar';

import Api from '@/services/api';

const useStyles = makeStyles((theme) => ({
  root: {
    backgroundColor: theme.palette.background.dark,
    minHeight: '100%',
    paddingBottom: theme.spacing(3),
    paddingTop: 72,
    marginLeft: 256
  }
}));

export default () => {
  const classes = useStyles();
  const [infoCounters, setInfoCounters] = useState({
    users: 0,
    admins: 0
  });

  useEffect(() => {
    Api.get('/api/info')
    .then(response => {
      setInfoCounters(response.data);
    });
  }, []);

  return (
    <>
      <TopBar />
      <SideBar />
      <Box className={classes.root}>
        <Container maxWidth={false}>
          <Grid container spacing={3}>
            <Grid item>
              <DashboardSimpleCard
                headerText="Users:"
                cardValue={infoCounters.users}
                customIcon={<PeopleIcon />}
              />
            </Grid>
            <Grid item>
              <DashboardSimpleCard
                headerText="Admins:"
                cardValue={infoCounters.admins}
                customIcon={<WarningIcon />}
              />
            </Grid>
            <Grid item>
              <DashboardSimpleCard
                headerText="Not admins:"
                cardValue={infoCounters.notAdmins}
                customIcon={<WarningIcon />}
              />
            </Grid>
          </Grid>
        </Container>
        <UsersList />
      </Box>
    </>
  );
};
