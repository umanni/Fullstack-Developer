import React from "react";

import { Breadcrumb } from "antd";

const Breadcrumbs: React.FC = () => {
 
  const route: any = { "/dashboard": "User", "/profile": "Profile" };
  const local_route = window.location.pathname;
  const title = route[`${local_route}`];

  return (
    <Breadcrumb style={{ margin: "16px 0" }}>
      <Breadcrumb.Item>Dashboard</Breadcrumb.Item>
      <Breadcrumb.Item>
        <a href={`${local_route}`}>{title}</a>
      </Breadcrumb.Item>
    </Breadcrumb>
  );
};

export default Breadcrumbs;
