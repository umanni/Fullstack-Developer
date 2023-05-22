import React, { useEffect, useState } from 'react';
import { Button, Input, Modal, Select, Table } from 'antd';
import { ColumnsType } from 'antd/es/table';
import {
  createUser,
  deleteUser,
  fetchUsers,
  updateUser,
} from '../../../lib/api';
import { useUser } from '../../../hooks/useUser';
import { DataType } from '../../../utils/DataType';
import { Content } from 'antd/es/layout/layout';
import './styles.scss';

const { Option } = Select;

const columns: ColumnsType<DataType> = [
  {
    title: 'ID',
    dataIndex: 'id',
  },
  {
    title: 'First Name',
    dataIndex: 'first_name',
  },
  {
    title: 'Last Name',
    dataIndex: 'last_name',
  },
  {
    title: 'Email',
    dataIndex: 'email',
  },
  {
    title: 'Profile',
    dataIndex: 'profile',
  },
  {
    title: 'Update',
    dataIndex: 'update',
    render: (_, record) => <UpdateButton record={record} />,
  },
  {
    title: 'Delete',
    dataIndex: 'delete',
    render: (_, record) => <DeleteButton record={record} />,
  },
];

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

      setCurrentUser(updatedUser);
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

const DeleteButton: React.FC<{ record: DataType }> = ({ record }) => {
  const [modalVisible, setModalVisible] = useState(false);

  const openModal = () => {
    setModalVisible(true);
  };

  const closeModal = () => {
    setModalVisible(false);
  };

  const handleDelete = async () => {
    try {
      await deleteUser(record.id);
      closeModal();
      window.location.reload();
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <>
      <Button onClick={openModal} type="danger">
        Delete
      </Button>
      <Modal
        title="Confirm Delete"
        open={modalVisible}
        onCancel={closeModal}
        footer={[
          <Button key="cancel" onClick={closeModal}>
            Cancel
          </Button>,
          <Button key="action" type="primary" onClick={handleDelete}>
            Delete
          </Button>,
        ]}
      >
        <p>Are you sure you want to delete this user?</p>
      </Modal>
    </>
  );
};

const RegisterButton: React.FC = () => {
  const [modalVisible, setModalVisible] = useState(false);
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [passwordConfirmation, setPasswordConfirmation] = useState('');
  const [profile, setProfile] = useState('');
  const [file, setFile] = useState<File | null>(null);

  const openModal = () => {
    setModalVisible(true);
  };

  const closeModal = () => {
    setModalVisible(false);
  };

  const handleRegister = async () => {
    try {
      if (file) {
        // Handle the file and create users
        const users = await processSpreadsheet(file);
        await createUsers(users);
      } else {
        // Create a single user
        await createUser(
          firstName,
          lastName,
          email,
          password,
          passwordConfirmation,
          profile
        );
      }

      closeModal();
      window.location.reload();
    } catch (err) {
      console.error(err);
    }
  };

  // Function to handle the file change
  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files.length > 0) {
      setFile(e.target.files[0]);
    }
  };

  return (
    <>
      <Button onClick={openModal}>Register</Button>
      <Modal
        title="Register User"
        open={modalVisible}
        onCancel={closeModal}
        footer={[
          <Button key="cancel" onClick={closeModal}>
            Cancel
          </Button>,
          <Button
            key="action"
            type="primary"
            disabled={password !== passwordConfirmation}
            onClick={handleRegister}
          >
            Register
          </Button>,
        ]}
      >
        {file ? (
          <p>File: {file.name}</p>
        ) : (
          <>
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
            <Input.Password
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="Password"
            />
            <Input.Password
              value={passwordConfirmation}
              onChange={(e) => setPasswordConfirmation(e.target.value)}
              placeholder="Confirm Password"
            />
            <Select
              value={profile}
              onChange={setProfile}
              placeholder="Select Profile"
            >
              <Option value="admin">Admin</Option>
              <Option value="client">Client</Option>
            </Select>
          </>
        )}
        <div>
          <label htmlFor="file-input">
            Upload Spreadsheet
            <input
              id="file-input"
              type="file"
              accept=".csv, application/vnd.openxmlformats-officedocument.spreadsheetml.sheet, application/vnd.ms-excel"
              onChange={handleFileChange}
              style={{ display: 'none' }}
            />
          </label>
        </div>
      </Modal>
    </>
  );
};

// Function to process the spreadsheet file
const processSpreadsheet = (file: File): Promise<DataType[]> => {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();

    reader.onload = (event: ProgressEvent<FileReader>) => {
      const result = event.target?.result;
      if (result && typeof result === 'string') {
        // Parse the spreadsheet data
        const users = parseSpreadsheetData(result);
        resolve(users);
      } else {
        reject(new Error('Failed to process spreadsheet.'));
      }
    };

    reader.onerror = () => {
      reject(new Error('Failed to read spreadsheet.'));
    };

    reader.readAsText(file);
  });
};

// Function to parse the spreadsheet data and extract user information
const parseSpreadsheetData = (data: string): DataType[] => {
  const rows = data.split('\n');
  const users: DataType[] = [];

  for (let i = 1; i < rows.length; i++) {
    const [
      firstName,
      lastName,
      email,
      password,
      passwordConfirmation,
      profile,
    ] = rows[i].split(',');

    const user: DataType = {
      key: i.toString(),
      id: i,
      first_name: firstName,
      last_name: lastName,
      email,
      password,
      password_confirmation: passwordConfirmation,
      profile,
    };

    users.push(user);
  }

  return users;
};

// Function to create multiple users
const createUsers = async (users: DataType[]): Promise<void> => {
  try {

    for (const user of users) {
      await createUser(
        user.first_name,
        user.last_name,
        user.email,
        user.password,
        user.password_confirmation,
        user.profile
      );
    }
  } catch (error) {
    throw new Error('Failed to create users.');
  }
};

const UserForm: React.FC = () => {
  const { currentUser, setCurrentUser } = useUser();
  const [data, setData] = useState<DataType[]>([]);
  const [clientCount, setClientCount] = useState(0);
  const [adminCount, setAdminCount] = useState(0);
  const [totalCount, setTotalCount] = useState(0);

  const fetchData = async () => {
    try {
      const users = await fetchUsers();
      const usersWithKeys = users.map((user) => ({
        ...user,
        key: user.id.toString(),
      }));

      const currentUserWithKey = currentUser
        ? { ...currentUser, key: currentUser.id.toString() }
        : null;

      setData(
        currentUserWithKey
          ? [currentUserWithKey, ...usersWithKeys]
          : usersWithKeys
      );

      const clientCount = usersWithKeys.filter(
        (user) => user.profile === 'client'
      ).length;
      const adminCount = usersWithKeys.filter(
        (user) => user.profile === 'admin'
      ).length;
      const totalCount = usersWithKeys.length;

      setClientCount(clientCount);
      setAdminCount(adminCount);
      setTotalCount(totalCount);
    } catch (error) {
      console.error(error);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  return (
    <Content className="table">
      <RegisterButton />
      <Content className="tableHeader">
        <p>Client Count: {clientCount}</p>
        <p>Admin Count: {adminCount}</p>
        <p>Total Count: {totalCount}</p>
      </Content>
      <Table columns={columns} dataSource={data} />
    </Content>
  );
};

export default UserForm;
