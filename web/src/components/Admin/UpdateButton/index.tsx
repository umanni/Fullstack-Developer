import { Button, Modal, Form, Input, Select } from 'antd';
import { useState } from 'react';
import { useUser } from '../../../hooks/useUser';
import { updateUser } from '../../../lib/api';
import { DataType } from '../../../utils/DataType';
import { EditTwoTone } from '@ant-design/icons';
import './styles.scss';

const { Option } = Select;

const UpdateButton: React.FC<{ record: DataType }> = ({ record }) => {
  const { setCurrentUser } = useUser();
  const [form] = Form.useForm();
  const [modalVisible, setModalVisible] = useState(false);

  const openModal = () => {
    form.setFieldsValue({
      firstName: record.first_name,
      lastName: record.last_name,
      email: record.email,
      profile: record.profile,
    });
    setModalVisible(true);
  };

  const closeModal = () => {
    setModalVisible(false);
  };

  const handleUpdate = async (values: any) => {
    try {
      const updatedUser = await updateUser(record.id, {
        first_name: values.firstName,
        last_name: values.lastName,
        email: values.email,
        profile: values.profile,
      });

      if (setCurrentUser) {
        setCurrentUser(updatedUser);
      }
      closeModal();
      window.location.reload();
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <>
      <Button onClick={openModal}>
        <EditTwoTone />
      </Button>
      <Modal
        title="Update User"
        open={modalVisible}
        onCancel={closeModal}
        footer={[
          <Button key="cancel" onClick={closeModal}>
            Cancel
          </Button>,
          <Button key="action" type="primary" onClick={() => form.submit()}>
            Update
          </Button>,
        ]}
      >
        <Form className="updateModal" form={form} onFinish={handleUpdate}>
          <Form.Item
            name="firstName"
            rules={[
              // { required: true, message: 'Please input your first name!' },
              {
                pattern: /^[A-Za-z]+$/,
                message: 'Please input alphabets only!',
              },
            ]}
          >
            <Input className="firstNameInput" placeholder="First Name" />
          </Form.Item>

          <Form.Item
            name="lastName"
            rules={[
              // { required: true, message: 'Please input your first name!' },
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
              // { required: true, message: 'Please input your email!' },
              {
                pattern: /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/i,
                message: 'Please enter a valid email address!',
              },
            ]}
          >
            <Input className="emailInput" placeholder="Email Address" />
          </Form.Item>
          <Form.Item
            name="profile"
            rules={[{ required: true, message: 'Please select a profile!' }]}
          >
            <Select className="selectProfile" placeholder="Select Profile">
              <Option value="admin">Admin</Option>
              <Option value="client">Client</Option>
            </Select>
          </Form.Item>
        </Form>
      </Modal>
    </>
  );
};

export default UpdateButton;
