import React, { useState, useEffect, useCallback } from "react";
import { useHistory } from "react-router-dom";
import {
  Form,
  Input,
  Button,
  Divider,
  message,
  Typography,
  Upload,
  Drawer,
  Space,
  Avatar,
} from "antd";

import {
  UserOutlined,
  LockOutlined,
  UploadOutlined,
  LoadingOutlined,
  PlusOutlined,
  EditOutlined,
  DeleteOutlined,
} from "@ant-design/icons";

import "antd/dist/antd.css";

import Api from "../../services/api";

import { useAuth } from "../../hooks/auth";

import ButtonCustom from "../../components/Button/Common";
import ButtonConfirm from "../../components/Button/Confirm";

import ProfileForm from "./form";

const { Title, Text } = Typography;

interface Profile {
  id: string;
  full_name: string;
  password: string;
  newPassword: string;
  avatar_image: any;
}

interface UploadInterface {
  loading?: any;
  imageUrl?: string;
}

function getBase64(img: any, callback: any) {
  const reader = new FileReader();
  reader.addEventListener("load", () => callback(reader.result));
  reader.readAsDataURL(img);
}

function beforeUpload(file: any) {
  const isJpgOrPng = file.type === "image/jpeg" || file.type === "image/png";
  if (!isJpgOrPng) {
    message.error("You can only upload JPG/PNG file!");
  }
  const isLt2M = file.size / 1024 / 1024 < 2;
  if (!isLt2M) {
    message.error("Image must smaller than 2MB!");
  }
  return isJpgOrPng && isLt2M;
}

const Profile = () => {
  const [form] = Form.useForm();
  const history = useHistory();

  const { user, updateUser, signOut } = useAuth();

  const [loadingUpload, setLoadingUpload] = useState<UploadInterface>({});
  const [visibleShowDrawer, setVisibleDrawer] = useState(false);

  const showDrawer = () => {
    setVisibleDrawer(true);
  };

  const onCloseDrawer = () => {
    setVisibleDrawer(false);
  };

  useEffect(() => {
    form.setFieldsValue({
      full_name: user.full_name,
    });
  }, []);

  const onFinish = () => {
    const avatar_image = loadingUpload.imageUrl ? loadingUpload.imageUrl : "";
    handleSubmit(avatar_image);
  };

  const handleSubmit = useCallback(
    async (avatar_image: string) => {
      try {
        const FormData = { avatar_image};

        await Api.put(`users/${user.id}`, { user: FormData });
        const responseUser = await Api.get("users/current");
        updateUser(responseUser.data);

        message.success("Updated profile with successfully!");

        handleClearForm();
      } catch (error) {
        message.error("Validations Fails: check your data!");
      }
    },
    [history, updateUser]
  );

  const handleClearForm = () => {
    form.resetFields();
  };

  const handleDeleteUser = async () => {
    try {
      await Api.delete(`users/${user.id}`);
      message.success("Account deleted!");
      signOut();
      history.push("/");
    } catch (error) {
      message.error("Error to delete account!");
    }
  };

  const handleChange = (info: any) => {
    if (info.file.status === "uploading") {
      setLoadingUpload({ loading: true });
      return;
    }
    if (info.file.status === "done") {
      getBase64(info.file.originFileObj, (imageUrl: any) =>
        setLoadingUpload({
          imageUrl,
          loading: false,
        })
      );
    }
  };

  const uploadButton = (
    <div>
      {loadingUpload.loading ? <LoadingOutlined /> : <PlusOutlined />}
      <div className="ant-upload-text">Upload</div>
    </div>
  );
  const { imageUrl } = loadingUpload;

  return (
    <div>
      <Title level={4}>Profile</Title>
      <Form
        form={form}
        name="normal_login"
        layout="vertical"
        className="login-form"
        initialValues={{
          size: "large",
        }}
        onFinish={onFinish}
      >
        <div
          style={{
            display: "flex",
            alignItems: "center",
            width: 500,
          }}
        >
          <Form.Item
            name="avatar_image"
            label="Image Profile"
            style={{ width: 140 }}
          >
            <Upload
              key="upload-2"
              accept=".png, jpg"
              name="avatar_image"
              listType="picture-card"
              className="avatar-uploader"
              showUploadList={false}
              action="https://www.mocky.io/v2/5cc8019d300000980a055e76"
              beforeUpload={beforeUpload}
              onChange={handleChange}
            >
              {imageUrl ? (
                <img src={imageUrl} alt="avatar" style={{ width: "100%" }} />
              ) : (
                uploadButton
              )}
            </Upload>
          </Form.Item>
          <Avatar
            style={{ marginRight: 15 }}
            src={user.avatar_image}
            shape="square"
            size={64}
            icon={<UserOutlined />}
          />
          <Space direction="vertical">
            <Text>Name: {user.full_name}</Text>
            <Text>E-mail: {user.email}</Text>
            <Text>Profile: {user.admin ? "Admin" : "NoAdmin"}</Text>
          </Space>
        </div>

        <Form.Item>
          <Button type="primary" htmlType="submit">
            <UploadOutlined />
            Change Image
          </Button>
          <Divider type="vertical" />
          <ButtonCustom
            name="Change Password"
            icon={<EditOutlined />}
            onClickAction={showDrawer}
          />
          <Divider type="vertical" />
          <ButtonConfirm
            name="Delete Account"
            title="Are you sure delete this Account?"
            content={`Sr. ${user.full_name} (${user.email})`}
            icon={<DeleteOutlined />}
            onConfirm={() => handleDeleteUser()}
            danger
          />
        </Form.Item>
      </Form>

      <Drawer
        title="Edit Profile"
        placement="right"
        closable={false}
        onClose={onCloseDrawer}
        visible={visibleShowDrawer}
      >
        <ProfileForm />
      </Drawer>
    </div>
  );
};

export default Profile;
