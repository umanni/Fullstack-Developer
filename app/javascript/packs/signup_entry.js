import React from "react";
import { render } from "react-dom";
import SignUp from '@/components/SignUp';

document.addEventListener("DOMContentLoaded", () => {
  render(
    <SignUp />,
    document.body.appendChild(document.createElement("div"))
  );
});

