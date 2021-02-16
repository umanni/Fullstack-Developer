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

import Api from '../services/api';
import { useAuth } from '../hooks/Auth';

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
  const [user, setUser] = useState();
  const { params } = useRouteMatch();
  const { signOut } = useAuth();
  const history = useHistory();

  useEffect(() => {
    const { id } = params;

    Api.get(`users/${id}`).then(response => {
      setUser(response.data);
    });
  }, [params]);

  const joinDate = useMemo(() => {
    if (user) {
      const tempDate = parseISO(user.created_at.toString());
      return format(tempDate, "'Joined' MM-dd-y 'at' HH:mm");
    }
    return null;
  }, [user]);

  const editLink = useMemo(() => {
    if (user) {
      return `/edit/${user.id}`;
    }
    return '/';
  }, [user]);

  const handleLogout = useCallback(async () => {
    await signOut();
    history.push('/sign_in');
  }, [history, signOut]);

  return (
    <Container maxWidth="sm" className={classes.root}>
      <Card className={classes.root}>
        <CardHeader
          title={user && user.full_name}
          subheader={user && joinDate}
          action={
            // eslint-disable-next-line react/jsx-wrap-multilines
            <Link to={editLink}>
              <IconButton aria-label="Edit profile">
                <EditIcon />
              </IconButton>
            </Link>
          }
        />
        <CardMedia
          className={classes.media}
          image={user && user.avatar_image}
          title={user && user.full_name}
        />
        <CardContent>
          <Typography variant="body2" color="textSecondary" component="p">
            {user && `Email: ${user.email}`}
          </Typography>
        </CardContent>
        <CardActions disableSpacing>
          <IconButton aria-label="Logout" onClick={handleLogout}>
            <ExitToAppIcon />
          </IconButton>
        </CardActions>
      </Card>
    </Container>
  );
};
