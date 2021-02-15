import React from 'react';
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';
import { AuthProvider } from '../hooks/Auth';
import Home from '../components/Home';
import SignIn from '../components/SignIn';
import SignUp from '../components/SignUp';
import Profile from '../components/Profile';

export default (
  <Router>
    <AuthProvider>
      <Switch>
        <Route path="/" exact component={Home} />
        <Route path="/sign_in" exact component={SignIn} />
        <Route path="/sign_up" exact component={SignUp} />
        <Route path="/profile/:id" exact component={Profile} />
        <Route path="/edit/:id" exact component={SignUp} />
      </Switch>
    </AuthProvider>
  </Router>
);
