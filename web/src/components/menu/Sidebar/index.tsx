import React, { useState } from "react";
import { Link } from "react-router-dom";

import Title from "antd/lib/typography/Title";
import { Layout, Menu } from "antd";
import { TagsOutlined, UserOutlined} from "@ant-design/icons";

const { Sider } = Layout;

const Sidebar: React.FC = () => {
  const [collapsedAction, setCollapsedAction] = useState(false);

  const showSidebar = () => {
    setCollapsedAction(!collapsedAction);
  };

  return (
    <Sider collapsible collapsed={collapsedAction} onCollapse={showSidebar}>
      <div>
        {" "}
        <Title style={{ marginLeft: "40px", color: "white" }} level={3}>
          Umanni
        </Title>
      </div>
      <Menu theme="dark" mode="inline" defaultSelectedKeys={["1"]}>
        <Menu.Item key="2" icon={<TagsOutlined />}>
          <Link to="/profile">Profile</Link>
        </Menu.Item>
        <Menu.Item key="1" icon={<UserOutlined />}>
          <Link to="/dashboard">User</Link>
        </Menu.Item>
      </Menu>
    </Sider>
  );
};

export default Sidebar;
