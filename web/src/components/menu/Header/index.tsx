import React, { useState } from "react";

import { Layout, Menu, Dropdown, Avatar, Drawer } from "antd";
import {
  ImportOutlined,
  DownOutlined,
  UserOutlined,
  LockOutlined,
} from "@ant-design/icons";

import { Container } from "./styles";

import Profile from "../../../pages/Profile/form";

import { useAuth } from "../../../hooks/auth";

const { Header } = Layout;

const HeaderNavbar: React.FC = () => {
  const { signOut, user } = useAuth();
  const [visibleShowDrawer, setVisibleDrawer] = useState(false);

  const showDrawer = () => {
    setVisibleDrawer(true);
  };

  const onCloseDrawer = () => {
    setVisibleDrawer(false);
  };

  const menu = (
    <Menu>
      <Menu.Item key="1" icon={<LockOutlined />} onClick={showDrawer}>
        Change Password
      </Menu.Item>
      <Menu.Item key="2" icon={<ImportOutlined />} onClick={signOut}>
        Sign Out
      </Menu.Item>
    </Menu>
  );

  return (
    <Container>
      <Header className="site-layout-background" style={{ padding: 0 }}>
        <div style={{ float: "right", border: "none", marginRight: 15 }}>
          <Avatar
            src={user.avatar_image}
            style={{ marginRight: 10 }}
            alt={!!user && user.full_name}
            icon={<UserOutlined />}
          />

          <Dropdown overlay={menu}>
            <a
              className="ant-dropdown-link"
              onClick={(e) => e.preventDefault()}
            >
              {!!user && user.email} <DownOutlined />
            </a>
          </Dropdown>
        </div>
      </Header>
      
      <Drawer
        title="Edit Profile"
        placement="right"
        closable={false}
        onClose={onCloseDrawer}
        visible={visibleShowDrawer}
      >
        <Profile />
      </Drawer>
    </Container>
  );
};

export default HeaderNavbar;
