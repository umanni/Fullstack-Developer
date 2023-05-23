import React, { useState } from 'react';
import { useUser } from '../../../hooks/useUser';
import { Form, Input, Button, Typography, Layout, Image, Modal } from 'antd';
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
      setCurrentUser(undefined);
      navigate('/');
    } catch (err) {
      console.error(err);
    }
  };

  const handleUpdate = async (values: any) => {
    try {
      const updatedUser = await updateUser(currentUser.id, {
        ...values,
      });
      setCurrentUser(updatedUser);
      setIsEditing(false);
    } catch (err) {
      console.error(err);
    }
  };

  const handleDelete = async () => {
    try {
      await deleteUser(currentUser.id);
      setCurrentUser(undefined);
      navigate('/');
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
      <Content
        className="container"
        style={{ padding: '50px', maxWidth: '800px', margin: '0 auto' }}
      >
        <Title level={2}>User Profile</Title>
        {currentUser && (
          <>
            <h3>
              Welcome, {currentUser.first_name} {currentUser.last_name}!
            </h3>

            {isEditing ? (
              <Form
                className="updateForm"
                form={form}
                onFinish={handleUpdate}
                initialValues={currentUser}
              >
                <Form.Item label="First Name" name="first_name">
                  <Input />
                </Form.Item>
                <Form.Item label="Last Name" name="last_name">
                  <Input />
                </Form.Item>
                <Form.Item label="Email" name="email">
                  <Input />
                </Form.Item>
                <Form.Item label="Image" name="image">
                  <Input />
                </Form.Item>
                <Form.Item label="Password" name="password">
                  <Input.Password />
                </Form.Item>
                <Form.Item
                  label="Password Confirmation"
                  name="password_confirmation"
                >
                  <Input.Password />
                </Form.Item>
                <Form.Item>
                  <Button
                    className="saveButton"
                    type="primary"
                    htmlType="submit"
                    disabled={!form.isFieldsTouched(true)}
                  >
                    Save
                  </Button>
                  <Button type="default" onClick={() => setIsEditing(false)}>
                    Cancel
                  </Button>
                </Form.Item>
              </Form>
            ) : (
              <>
                <Image
                  src={currentUser.image}
                  className="imageProfile"
                  alt="Profile Image"
                />
                <Button
                  className="editButton"
                  onClick={() => setIsEditing(true)}
                >
                  Edit Details
                </Button>
              </>
            )}
            <Button className="logoutButton" onClick={handleLogout}>
              Logout
            </Button>
            <Button className="deleteButton" onClick={openModal}>
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
          </>
        )}
      </Content>
    </Layout>
  );
};

export default ProfilePage;
