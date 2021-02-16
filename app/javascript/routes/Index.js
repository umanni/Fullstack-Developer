import React from 'react';
import { BrowserRouter as Router, Switch } from 'react-router-dom';

import Route from '@/routes/Route';

import MainProvider from '@/contexts/MainContext';
import Profile from '@/components/Profile';
import Dashboard from '@/components/Dashboard';

export default (
  <Router>
    <MainProvider>
      <Switch>
        <Route path="/profile" exact isPrivate component={Profile} />
        <Route path="/dashboard" exact isPrivate isAdmin component={Dashboard} />
      </Switch>
    </MainProvider>
  </Router>
);
