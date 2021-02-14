import React from 'react';
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';
import Home from '../components/Home';
import SignIn from '../components/SignIn';

export default (
  <Router>
    <Switch>
      <Route path="/" exact component={Home} />
      <Route path="/sign_in" exact component={SignIn} />
    </Switch>
  </Router>
);
