import { Button, Modal, Input, Select } from 'antd';
import { useState } from 'react';
import { createUser } from '../../../lib/api';
import { DataType } from '../../../utils/DataType';

const { Option } = Select;

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
      <Button onClick={openModal} type="primary">
        Register
      </Button>
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
      try {
        await createUser(
          user.first_name,
          user.last_name,
          user.email,
          user.password,
          user.password_confirmation,
          user.profile
        );
      } catch (error) {
        console.error('Failed to create user:', user, error);
      }
    }
  } catch (error) {
    throw new Error('Failed to create users.');
  }
};

export default RegisterButton;
