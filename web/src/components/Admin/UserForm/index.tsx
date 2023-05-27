import React, { useCallback, useEffect, useState } from 'react';
import { Layout, Statistic, Table } from 'antd';
import { ColumnsType } from 'antd/es/table';
import { fetchUsers } from '../../../lib/api';
import { DataType } from '../../../utils/DataType';
import { Content } from 'antd/es/layout/layout';
import UpdateButton from '../UpdateButton';
import DeleteButton from '../DeleteButton';
import RegisterButton from '../RegisterButton';
import Card from 'antd/es/card/Card';
import CountUp from 'react-countup';
import Title from 'antd/es/typography/Title';
import { Formatter } from 'antd/lib/statistic/utils';
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
  const [data, setData] = useState<DataType[]>([]);
  const [clientCount, setClientCount] = useState(0);
  const [adminCount, setAdminCount] = useState(0);
  const [totalCount, setTotalCount] = useState(0);

  const formatter: Formatter = (value) => (
    <CountUp start={0} end={value as number} duration={1} separator="," />
  );

  const fetchData = useCallback(async () => {
    try {
      const users = await fetchUsers();
      const usersWithKeys = users.map((user: DataType) => ({
        ...user,
        key: user.id.toString(),
      }));

      setData(usersWithKeys);

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
  }, []);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  return (
    <Layout>
      <Content className="adminHeader">
        <Card>
          <Statistic
            title="Client Count"
            value={clientCount}
            className="counters"
            formatter={formatter}
          />
        </Card>

        <Card>
          <Statistic
            title="Admin Count"
            value={adminCount}
            className="counters"
            formatter={formatter}
          />
        </Card>

        <Card>
          <Statistic
            title="Total Count"
            value={totalCount}
            className="counters"
            formatter={formatter}
          />
        </Card>
      </Content>

      <Content>
        <div className="tableHeader">
          <Title level={2}>Data Table</Title>
          <RegisterButton />
        </div>
        <Table className="dataTable" columns={columns} dataSource={data} />
      </Content>
    </Layout>
  );
};

export default UserForm;
