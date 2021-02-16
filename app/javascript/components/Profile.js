import React, {
  useEffect,
  useState,
  useMemo,
  useCallback,
  useContext,
} from 'react';
import { Link, useHistory, useRouteMatch } from 'react-router-dom';
import {
  Container,
  makeStyles,
  Card,
  CardHeader,
  CardMedia,
  CardContent,
  CardActions,
  IconButton,
  Typography,
} from '@material-ui/core';
import { red } from '@material-ui/core/colors';
import EditIcon from '@material-ui/icons/Edit';
import ExitToAppIcon from '@material-ui/icons/ExitToApp';
import { parseISO, format } from 'date-fns';

import Api from '@/services/api';
import {MainContext} from '@/contexts/MainContext';

const useStyles = makeStyles(() => ({
  root: {
    maxWidth: 720,
  },
  media: {
    height: 0,
    paddingTop: '80%',
  },
  avatar: {
    backgroundColor: red[500],
  },
}));

export default () => {
  const classes = useStyles();
  const {currentUser} = useContext(MainContext);
  const history = useHistory();

  const joinDate = useMemo(() => {
    if (!currentUser.created_at) return;

    const tempDate = parseISO(currentUser.created_at.toString());
    return format(tempDate, "'Joined' MM-dd-y 'at' HH:mm");
  }, [currentUser]);

  const editLink = useMemo(() => {
    return `/edit/${currentUser.id}`;
  }, [currentUser]);

  return (
    <Container maxWidth="sm" className={classes.root}>
      <Card className={classes.root}>
        <CardHeader
          title={currentUser.full_name}
          subheader={joinDate}
          action={
            // eslint-disable-next-line react/jsx-wrap-multilines
            <Link to={editLink}>
              <IconButton aria-label="Edit profile">
                <EditIcon />
              </IconButton>
            </Link>
          }
        />
        {currentUser.avatar_image && (
          <CardMedia
            className={classes.media}
            image={currentUser.avatar_image}
            title={currentUser.full_name}
          />
        )}
        <CardContent>
          <Typography variant="body2" color="textSecondary" component="p">
            {`Email: ${currentUser.email}`}
          </Typography>
        </CardContent>
        <CardActions disableSpacing>
          <IconButton aria-label="Logout">
            <ExitToAppIcon />
          </IconButton>
        </CardActions>
      </Card>
    </Container>
  );
};
