import React from "react";

import "antd/dist/antd.css";
import { Layout } from "antd";
import { Container } from "./styles";

import HeaderNavbar from "../../../components/menu/Header";
import Sidebar from "../../../components/menu/Sidebar";
import Breadcrumb from "../../../components/menu/Breadcrumb";
import Footer from "../../../components/menu/Footer";

const { Content } = Layout;

const authorized: React.FC = ({ children }) => {
  return (
    <Container>
      <Layout style={{ minHeight: "100vh" }}>
        <Sidebar />
        <Layout className="site-layout">
          <HeaderNavbar />
          <Content style={{ padding: "0 16px" }}>
            <Breadcrumb />
            <div
              className="site-layout-background"
              style={{ padding: 24, minHeight: 360 }}
            >
              {children}
            </div>
          </Content>
          <Footer title="Umanni ©2020 Created by Tiago Leal" />
        </Layout>
      </Layout>
    </Container>
  );
};

export default authorized;
