import React, { useState } from 'react';
import { useUser } from '../../../hooks/useUser';
import {
  Form,
  Input,
  Button,
  Typography,
  Layout,
  Image,
  Modal,
  Avatar,
} from 'antd';
import { useNavigate } from 'react-router-dom';
import { logoutUser, updateUser, deleteUser } from '../../../lib/api';
import './styles.scss';

const { Content } = Layout;
const { Title } = Typography;

const ProfilePage: React.FC = () => {
  const { currentUser, setCurrentUser } = useUser();
  const navigate = useNavigate();
  const [form] = Form.useForm();
  const [isEditing, setIsEditing] = useState(false);
  const [modalVisible, setModalVisible] = useState(false);

  const handleLogout = async () => {
    try {
      await logoutUser();
      if (setCurrentUser) {
        setCurrentUser(undefined);
      }
      navigate('/');
    } catch (err) {
      console.error(err);
    }
  };

  const handleUpdate = async (values: any) => {
    try {
      if (currentUser !== undefined) {
        const updatedUser = await updateUser(currentUser.id, {
          ...values,
        });
        if (setCurrentUser) {
          setCurrentUser(updatedUser);
        }
        setIsEditing(false);
      }
    } catch (err) {
      console.error(err);
    }
  };

  const handleDelete = async () => {
    try {
      if (currentUser !== undefined) {
        await deleteUser(currentUser.id);
        if (setCurrentUser) {
          setCurrentUser(undefined);
        }
        navigate('/');
      }
    } catch (err) {
      console.error(err);
    }
  };

  const openModal = () => {
    setModalVisible(true);
  };

  const closeModal = () => {
    setModalVisible(false);
  };

  return (
    <Layout>
      <Content className="profileContainer">
        {currentUser !== undefined && (
          <>
            {isEditing ? (
              <Form
                className="updateForm"
                form={form}
                onFinish={handleUpdate}
                initialValues={currentUser}
              >
                <div className="updateFormTitle">
                  <Title level={3}>Update your profile</Title>
                </div>
                <Form.Item
                  name="first_name"
                  rules={[
                    {
                      required: true,
                      message: 'Please input your first name!',
                    },
                    {
                      pattern: /^[A-Za-z]+$/,
                      message: 'Please input alphabets only!',
                    },
                  ]}
                >
                  <Input className="firstNameInput" placeholder="First Name" />
                </Form.Item>

                <Form.Item
                  name="last_name"
                  rules={[
                    {
                      pattern: /^[A-Za-z]+$/,
                      message: 'Please input alphabets only!',
                    },
                  ]}
                >
                  <Input className="lastNameInput" placeholder="Last Name" />
                </Form.Item>

                <Form.Item
                  name="email"
                  rules={[
                    {
                      pattern:
                        /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/i,
                      message: 'Please enter a valid email address!',
                    },
                  ]}
                >
                  <Input className="emailInput" placeholder="Email Address" />
                </Form.Item>

                <Form.Item name="image">
                  <Input className="imageInput" placeholder="Image URL" />
                </Form.Item>

                <Form.Item name="password">
                  <Input.Password
                    className="passwordInput"
                    placeholder="Password"
                  />
                </Form.Item>

                <Form.Item
                  name="password_confirmation"
                  rules={[
                    ({ getFieldValue }) => ({
                      validator(_, value) {
                        if (!value || getFieldValue('password') === value) {
                          return Promise.resolve();
                        }
                        return Promise.reject(
                          'The two passwords do not match!'
                        );
                      },
                    }),
                  ]}
                >
                  <Input.Password
                    className="passwordConfirmationInput"
                    placeholder="Password Confirmation"
                  />
                </Form.Item>
                <Form.Item>
                  <div className="updateProfileSaveButtons">
                    <Button
                      type="primary"
                      htmlType="submit"
                      disabled={!form.isFieldsTouched(true)}
                    >
                      Save
                    </Button>
                    <Button type="default" onClick={() => setIsEditing(false)}>
                      Cancel
                    </Button>
                  </div>
                </Form.Item>
              </Form>
            ) : (
              <>
                <Avatar
                  size={128}
                  src={currentUser.image}
                  className="imageProfile"
                  alt="Profile Image"
                />

                <Title className="nameContainer" level={3}>
                  Welcome, {currentUser?.first_name} {currentUser?.last_name}!
                </Title>

                <div className="buttonsContainer">
                  <Button
                    className="profileEditButton"
                    type="primary"
                    onClick={() => setIsEditing(true)}
                  >
                    Edit Details
                  </Button>
                  <Button
                    className="profileLogoutButton"
                    type="primary"
                    danger
                    onClick={handleLogout}
                  >
                    Logout
                  </Button>
                  <Button
                    className="profileDeleteButton"
                    danger
                    onClick={openModal}
                  >
                    Delete User
                  </Button>
                  <Modal
                    title="Confirm Delete"
                    open={modalVisible}
                    onOk={handleDelete}
                    onCancel={closeModal}
                  >
                    <p>Are you sure you want to delete your user account?</p>
                  </Modal>
                </div>
              </>
            )}
          </>
        )}
      </Content>
    </Layout>
  );
};

export default ProfilePage;
