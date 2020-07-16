import React from "react";

import { Wrapper } from "./styles";

interface Props {
  children: any;
}

const notAuthorized: React.FC<Props> = ({ children }) => {
  return <Wrapper>{children}</Wrapper>;
};

export default notAuthorized;
