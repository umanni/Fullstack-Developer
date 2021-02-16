import React from 'react';
import {
  Container,
  Grid,
  makeStyles,
  Box
} from '@material-ui/core';
import PeopleIcon from '@material-ui/icons/PeopleOutlined';
import WarningIcon from '@material-ui/icons/WarningOutlined';

import TopBar from '@/components/TopBar'
import DashboardSimpleCard from '@/components/DashboardSimpleCard'

const useStyles = makeStyles((theme) => ({
  root: {
    backgroundColor: theme.palette.background.dark,
    minHeight: '100%',
    paddingBottom: theme.spacing(3),
    paddingTop: 72,
  }
}));

export default () => {
  const classes = useStyles();

  return (
    <>
      <TopBar></TopBar>
      <Box className={classes.root}>
        <Container maxWidth={false}>
          <Grid container spacing={3}>
            <Grid item>
              <DashboardSimpleCard
                headerText="Users:"
                cardValue="10"
                customIcon={<PeopleIcon />}
              />
            </Grid>
            <Grid item>
              <DashboardSimpleCard
                headerText="Administrators:"
                cardValue="5"
                customIcon={<WarningIcon />}
              />
            </Grid>
          </Grid>
        </Container>
      </Box>
    </>
  );
};
