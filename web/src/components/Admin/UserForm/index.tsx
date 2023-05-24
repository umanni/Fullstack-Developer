import React, { useCallback, useEffect, useState } from 'react';
import { Layout, Table } from 'antd';
import { ColumnsType } from 'antd/es/table';
import { fetchUsers } from '../../../lib/api';
import { useUser } from '../../../hooks/useUser';
import { DataType } from '../../../utils/DataType';
import { Content } from 'antd/es/layout/layout';
import UpdateButton from '../UpdateButton';
import DeleteButton from '../DeleteButton';
import RegisterButton from '../RegisterButton';
import './styles.scss';

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

const UserForm: React.FC = () => {
  const { currentUser } = useUser();
  const [data, setData] = useState<DataType[]>([]);
  const [clientCount, setClientCount] = useState(0);
  const [adminCount, setAdminCount] = useState(0);
  const [totalCount, setTotalCount] = useState(0);

  const fetchData = useCallback(async () => {
    try {
      const users = await fetchUsers();
      const usersWithKeys = users.map((user: DataType) => ({
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
        (user: DataType) => user.profile === 'client'
      ).length;
      const adminCount = usersWithKeys.filter(
        (user: DataType) => user.profile === 'admin'
      ).length;
      const totalCount = usersWithKeys.length;

      setClientCount(clientCount);
      setAdminCount(adminCount);
      setTotalCount(totalCount);
    } catch (error) {
      console.error(error);
    }
  }, [currentUser]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  return (
    <Layout>
      <Content className="table">
        <RegisterButton />
        <Content className="tableHeader">
          <p>Client Count: {clientCount}</p>
          <p>Admin Count: {adminCount}</p>
          <p>Total Count: {totalCount}</p>
        </Content>
        <Table columns={columns} dataSource={data} />
      </Content>
    </Layout>
  );
};

export default UserForm;
