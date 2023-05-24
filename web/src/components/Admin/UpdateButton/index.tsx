import { Button, Modal, Input, Select } from 'antd';
import { useState } from 'react';
import { useUser } from '../../../hooks/useUser';
import { updateUser } from '../../../lib/api';
import { DataType } from '../../../utils/DataType';

const { Option } = Select;

const UpdateButton: React.FC<{ record: DataType }> = ({ record }) => {
  const { setCurrentUser } = useUser();
  const [modalVisible, setModalVisible] = useState(false);
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [email, setEmail] = useState('');
  const [profile, setProfile] = useState('');

  const openModal = () => {
    setFirstName(record.first_name);
    setLastName(record.last_name);
    setEmail(record.email);
    setProfile(record.profile);
    setModalVisible(true);
  };

  const closeModal = () => {
    setModalVisible(false);
  };

  const handleUpdate = async () => {
    try {
      const updatedUser = await updateUser(record.id, {
        first_name: firstName,
        last_name: lastName,
        email: email,
        profile: profile,
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
      <Button onClick={openModal}>Update</Button>
      <Modal
        title="Update User"
        open={modalVisible}
        onCancel={closeModal}
        footer={[
          <Button key="cancel" onClick={closeModal}>
            Cancel
          </Button>,
          <Button key="action" type="primary" onClick={handleUpdate}>
            Update
          </Button>,
        ]}
      >
        <Input
          value={firstName}
          onChange={(e) => setFirstName(e.target.value)}
          placeholder="First Name"
        />
        <Input
          value={lastName}
          onChange={(e) => setLastName(e.target.value)}
          placeholder="Last Name"
        />
        <Input
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="Email"
        />
        <Select
          value={profile}
          onChange={setProfile}
          placeholder="Select Profile"
        >
          <Option value="admin">Admin</Option>
          <Option value="client">Client</Option>
        </Select>
      </Modal>
    </>
  );
};

export default UpdateButton;
