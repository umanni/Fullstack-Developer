import React from "react";
import { render } from "react-dom";
import SignIn from '@/components/SignIn';

document.addEventListener("DOMContentLoaded", () => {
  render(
    <SignIn />,
    document.body.appendChild(document.createElement("div"))
  );
});

