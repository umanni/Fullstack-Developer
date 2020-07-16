import React, { useEffect, useCallback } from "react";

import {
  Form,
  message,
  Input,
  Button,
  Select,
  Divider,
} from "antd";

import Api from "../../services/api";

interface User {
  id: number;
  full_name: string;
  email: string;
  role: string;
  password: string;
}

type Props = {
  selectedUser?: User;
  onLoadUsers(): void;
};

const UserForm: React.FC<Props> = ({ selectedUser, onLoadUsers }) => {
  const [form] = Form.useForm();
  
  const onFinish = (values: any) => {
    handleSubmit(values);
  };

  const handleSubmit = useCallback(async (user: User) => {
    try {
      if (selectedUser?.id) {
        await Api.put(`/users/${selectedUser?.id}`, { user });
        message.success(`User:${user.full_name} successfully updated!`);
      } else {
        Api.post(`/users/`, { user });
        message.success(`User:${user.full_name} successfully registered!`);
      }

      handleClearForm();
      onLoadUsers();
    } catch (error) {
      message.error("Validations Fails: check your data!");
    }
  }, []);

  useEffect(() => {
    handleClearForm();
    form.setFieldsValue({
      full_name: selectedUser?.full_name,
      email: selectedUser?.email,
      role: selectedUser?.role,
      password: "",
    });
  }, [selectedUser]);

  const handleClearForm = () => {
    form.resetFields();
  };

  return (
    <Form
      form={form}
      layout="vertical"
      key="form-product"
      size="large"
      onFinish={onFinish}
      initialValues={{
        size: "large",
        password: "",
      }}
    >
      <Form.Item
        label="Name"
        name="full_name"
        rules={[
          {
            required: true,
            message: "Please input your name",
          },
        ]}
      >
        <Input placeholder="Please input Full Name" />
      </Form.Item>

      <Form.Item
        label="E-mail"
        name="email"
        
        rules={[
          {
            required: true,
            message: "Please input E-mail",
            type:'email',
          },
        ]}
      >
        <Input placeholder="Please input E-mail" />
      </Form.Item>

      <Form.Item
        label="Role"
        name="role"
        hasFeedback
        rules={[{ required: true, message: "Please select Role!" }]}
      >
        <Select placeholder="Please select a option">
          <Select.Option value="admin">admin</Select.Option>
          <Select.Option value="noadmin">no-admin</Select.Option>
        </Select>
      </Form.Item>

      <Form.Item
        label="Password"
        name="password"
        rules={[{ required: true, message: "Please input your Password!" }]}
      >
        <Input.Password allowClear={true} placeholder="Password" />
      </Form.Item>

      <Form.Item>
        <Button type="primary" htmlType="submit">
          Submit
        </Button>
        <Divider type="vertical" />
        <Button htmlType="button" onClick={handleClearForm}>
          Reset
        </Button>
      </Form.Item>
    </Form>
  );
};

export default UserForm;
