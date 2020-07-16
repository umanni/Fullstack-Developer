import React from "react";

import { Layout } from "antd";

const { Footer } = Layout;

interface FooterInterface {
  title?: string;
}

const FooterModel: React.FC<FooterInterface> = ({
  title = "Ant Design ©2018 Created by Ant UED",
}) => {
  return <Footer style={{ textAlign: "center" }}>{title}</Footer>;
};

export default FooterModel;
