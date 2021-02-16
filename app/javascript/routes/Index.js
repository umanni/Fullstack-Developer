import React from 'react';
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';
import MainProvider from '@/contexts/MainContext';
import Profile from '@/components/Profile';

export default (
  <Router>
    <MainProvider>
      <Switch>
        <Route path="/" exact component={Profile} />
      </Switch>
    </MainProvider>
  </Router>
);
