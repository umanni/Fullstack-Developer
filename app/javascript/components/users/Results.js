import React, { useState, useCallback } from 'react';
import { Link } from 'react-router-dom';
import clsx from 'clsx';
import PropTypes from 'prop-types';
import PerfectScrollbar from 'react-perfect-scrollbar';
import {
  Avatar,
  Box,
  Card,
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
  Typography,
  IconButton,
  makeStyles
} from '@material-ui/core';
import EditIcon from '@material-ui/icons/Edit';
import CheckIcon from '@material-ui/icons/Check';
import ClearIcon from '@material-ui/icons/Clear';
import DeleteIcon from '@material-ui/icons/Delete';

import Api from '@/services/api';

const useStyles = makeStyles((theme) => ({
  root: {},
  avatar: {
    marginRight: theme.spacing(2)
  }
}));

const Results = ({ className, customData, ...rest }) => {
  const classes = useStyles();
  const [limit, setLimit] = useState(10);

  const handleUserDelete = useCallback((id) => {
    Api.delete(`/api/users/${id}`)
    .then(() => {
      location.reload();
    });
  }, []);

  return (
    <Card
      className={clsx(classes.root, className)}
      {...rest}
    >
      <PerfectScrollbar>
        <Box minWidth={1050}>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>
                  Name
                </TableCell>
                <TableCell>
                  Email
                </TableCell>
                <TableCell>
                  Avatar location
                </TableCell>
                <TableCell>
                  Created at
                </TableCell>
                <TableCell>
                  Admin
                </TableCell>
                <TableCell>
                  Actions
                </TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {customData.slice(0, limit).map((item) => (
                <TableRow
                  hover
                  key={item.id}
                >
                  <TableCell>
                    <Box
                      alignItems="center"
                      display="flex"
                    >
                      <Avatar
                        className={classes.avatar}
                        src={item.avatar_image}
                      >
                      </Avatar>
                      <Typography
                        color="textPrimary"
                        variant="body1"
                      >
                        {item.full_name}
                      </Typography>
                    </Box>
                  </TableCell>
                  <TableCell>
                    {item.email}
                  </TableCell>
                  <TableCell>
                    {item.avatar_image}
                  </TableCell>
                  <TableCell>
                    {item.created_at}
                  </TableCell>
                  <TableCell>
                    {
                      item.admin
                      ? (<CheckIcon style={{color: 'green'}} />)
                      : (<ClearIcon style={{color: 'red'}} />)
                    }
                  </TableCell>
                  <TableCell>
                    <IconButton>
                      <Link to={`/edit/${item.id}`} style={{color: 'black'}}>
                        <EditIcon />
                      </Link>
                    </IconButton>
                    <IconButton onClick={() => {handleUserDelete(item.id)}} style={{color: 'red'}}>
                      <DeleteIcon />
                    </IconButton>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </Box>
      </PerfectScrollbar>
    </Card>
  );
};

Results.propTypes = {
  className: PropTypes.string,
  customData: PropTypes.array.isRequired
};

export default Results;
