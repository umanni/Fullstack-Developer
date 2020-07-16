import React, { useCallback } from "react";
import { Link } from "react-router-dom";

import { Form, Input, Button, Avatar, message, Typography } from "antd";
import { UserOutlined, LockOutlined } from "@ant-design/icons";
import "antd/dist/antd.css";

import { Container, Content } from "./styles";
import { useAuth } from "../../hooks/auth";

const { Title } = Typography;

interface SignInFormData {
  email: string;
  password: string;
}

const SignIn: React.FC = () => {
  const { signIn } = useAuth();
  
  const onFinish = (values: any) => {
    handleSubmit(values);
  };

  const handleSubmit = useCallback(
    async (data: SignInFormData) => {
      try {
        await signIn({
          email: data.email,
          password: data.password,
        });
      } catch (error) {
        message.error("Login Fails!");
      }
    },
    [signIn]
  );

  return (
    <Container>
      <Content>
        <Avatar
          className="avatar"
          size={64}
          src="https://zos.alipayobjects.com/rmsportal/ODTLcjxAfvqbxHnVXCYX.png"
        />
        <Title className="title" level={4}>
          Log in to your account
        </Title>
        <Form
          name="normal_login"
          className="login-form"
          initialValues={{ remember: true }}
          onFinish={onFinish}
        >
          <Form.Item
            name="email"
            rules={[{ required: true, message: "Please input your Username!" }]}
          >
            <Input
              prefix={<UserOutlined className="site-form-item-icon" />}
              placeholder="E-mail"
            />
          </Form.Item>
          <Form.Item
            name="password"
            rules={[{ required: true, message: "Please input your Password!" }]}
          >
            <Input
              prefix={<LockOutlined className="site-form-item-icon" />}
              type="password"
              placeholder="Password"
            />
          </Form.Item>

          <Form.Item>
            <Button
              type="primary"
              htmlType="submit"
              className="login-form-button"
            >
              Log in
            </Button>
            Ou <Link to="/signup">Criar conta</Link>
          </Form.Item>
        </Form>
      </Content>
    </Container>
  );
};

export default SignIn;
