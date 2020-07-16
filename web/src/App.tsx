import React from "react";
import "./App.css";

import DefaultStyle from "./styles/default";

import AppProvider from "./hooks";

import Routes from "./routes";

import { BrowserRouter as Router } from "react-router-dom";

function App() {
  return (
    <Router>
      <AppProvider>
        <Routes />
      </AppProvider>
      <DefaultStyle />
    </Router>
  );
}

export default App;
