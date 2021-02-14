import React from 'react';
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';
import Home from '../components/Home';
import SignIn from '../components/SignIn';
import SignUp from '../components/SignUp';

export default (
  <Router>
    <Switch>
      <Route path="/" exact component={Home} />
      <Route path="/sign_in" exact component={SignIn} />
      <Route path="/sign_up" exact component={SignUp} />
    </Switch>
  </Router>
);
