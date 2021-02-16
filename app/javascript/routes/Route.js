import React, {useContext} from 'react';
import {
  Route as ReactDOMRoute,
  Redirect,
} from 'react-router-dom';

import { MainContext } from '@/contexts/MainContext';

const Route = ({
  isPrivate = false,
  isAdmin = false,
  component: Component,
  ...rest
}) => {
  const { currentUser } = useContext(MainContext);

  return (
    <ReactDOMRoute
      {...rest}
      render={({ location }) => {
        return isPrivate === !!currentUser.id ? (
          <Component />
        ) : (
          <Redirect
            to={{
              pathname: isPrivate ? '/' : currentUser.admin ? '/dashboard' : '/profile',
              state: { from: location },
            }}
          />
        );
      }}
    />
  );
};

export default Route;
