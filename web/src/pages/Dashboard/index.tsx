import React, { useState, useEffect, useCallback } from "react";

import Api from "../../services/api";
import { useAuth } from "../../hooks/auth";

import "antd/dist/antd.css";
import {
  message,
  Table,
  Divider,
  Drawer,
  Typography,
  Button
} from "antd";
import { EditOutlined, DeleteOutlined, PlusOutlined, UserOutlined } from "@ant-design/icons";

import ButtonConfirm from "../../components/Button/Confirm";
import ButtonCustom from "../../components/Button/Common";
import UploadProgress from "../../components/UploadProgress";
import CardStatistic from "../../components/CardStatistic";
import UserForm from "./form";

const { Title } = Typography;

type UserTransaction = {
  id: number;
  full_name: string;
  email: string;
  role: string;
  password: string;
  users_count: number;
  users_count_group: {
    admin: number;
    noadmin: number;
  };
};

type UserStatistic = {
  users: number;
  admin: number;
  noadmin: number;
};

const User = () => {
  const [visibleShowDrawer, setVisibleDrawer] = useState(false);
  const [selectedUser, setSelectedUser] = useState();
  const [userList, setUserList] = useState<UserTransaction[]>([]);
  const [userTotal, setUserTotal] = useState<UserStatistic>(
    {} as UserStatistic
  );

  const { checkProfileUser } = useAuth();

  const showDrawer = () => {
    setVisibleDrawer(true);
  };

  const onCloseDrawer = () => {
    setVisibleDrawer(false);
  };

  useEffect(() => {
    checkProfileUser();
    onLoadUsers();
  }, []);

  const onLoadUsers = useCallback(
    (params = {}) => {
      try {
        Api.get("users", {
          params,
        }).then((response) => {
          const users = response.data.map((user: UserTransaction) => {
            setUserTotal({
              users: user.users_count,
              admin: user.users_count_group.admin,
              noadmin: user.users_count_group.noadmin,
            });
            return {
              ...user,
              key: user.id,
            };
          });

          setUserList(users);
        });
      } catch (error) {
        message.error(error);
      }
    },
    [userList]
  );

  const handleAddUser = () => {
    setSelectedUser({} as UserTransaction);
    showDrawer();
  };



  const columns = [
    {
      title: "ID",
      dataIndex: "id",
      key: "id",
      sorter: {
        compare: (a: any, b: any) => a.id - b.id,
        multiple: 2,
      },
    },
    {
      title: "Full Name",
      dataIndex: "full_name",
      key: "full_name",
      sorter: {
        compare: (a: any, b: any) => a.full_name - b.full_name,
        multiple: 2,
      },
    },
    {
      title: "E-mail",
      dataIndex: "email",
      key: "email",
      sorter: {
        compare: (a: any, b: any) => a.email - b.email,
        multiple: 2,
      },
    },
    {
      title: "Role",
      dataIndex: "role",
      key: "role",
      sorter: {
        compare: (a: any, b: any) => a.role - b.role,
        multiple: 2,
      },
    },
    {
      title: "Action",
      key: "action",
      render: (action: any, user: UserTransaction) => {
        return (
          <>
            <ButtonCustom
              name="Edit"
              icon={<EditOutlined />}
              onClickAction={() => handleEditUser(user)}
            />

            <Divider type="vertical" />
            <ButtonConfirm
              name="Delete"
              title="Are you sure delete this User?"
              content={`ID: ${user.id} - User: ${user.full_name}`}
              icon={<DeleteOutlined />}
              onConfirm={() => handleDeleteUser(user.id)}
              danger
            />
            
            <Divider type="vertical" />
            <Button type="primary" 
              style={{backgroundColor: "green",borderColor: "green" }} 
              onClick={() => handleChangeRole(user)} 
              icon={<UserOutlined />} 
            >
              Change role
            </Button>
          </>
        );
      },
    },
  ];

  const handleEditUser = (user: UserTransaction) => {
    showDrawer();
    setSelectedUser(user);
  };

  const handleChangeRole= (user_edit: UserTransaction) => {
    try {

      const user = {
        role: user_edit.role == "admin" ? "noadmin" : "admin"
      }

      Api.put(`/users/${user_edit.id}`, user)
        .then(() => {
          message.success(`User:${user_edit.full_name} successfully change role!`);
          onLoadUsers();
        });
      
    }catch (error) {
      message.error("Error to change user role!");
    }
  }
  

  const handleDeleteUser = async (id: number) => {
    try {
      await Api.delete(`users/${id}`);
      message.success("User deleted!");
      onLoadUsers();
    } catch (error) {
      message.error("Error to delete user!");
    }
  };

  const statistic = [
    {
      title: "Total Users",
      value: userTotal.users,
    },
    {
      title: "Admin Users",
      value: userTotal.admin,
    },
    {
      title: "No-Admin Users",
      value: userTotal.noadmin,
    },
  ];

  return (
    <div>
      <CardStatistic statisticData={statistic} />
      <div
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
        }}
      >
        <Divider type="vertical" />
        <Title level={4}>List Users</Title>

        <ButtonCustom
          name="Add"
          icon={<PlusOutlined />}
          onClickAction={handleAddUser}
        />
      </div>

      <Drawer
        title={selectedUser?.id ? "Edit User" : "Add User"}
        placement="right"
        closable={false}
        onClose={onCloseDrawer}
        visible={visibleShowDrawer}
      >
        <UserForm
          key={selectedUser?.id}
          selectedUser={selectedUser}
          onLoadUsers={onLoadUsers}
        />
      </Drawer>

      <UploadProgress name="Import excel file" onLoadUsers={onLoadUsers} />
      <br />

      <Table
        rowKey="id"
        columns={columns}
        pagination={false}
        dataSource={userList}
      />
      
    </div>
  );
};

export default User;
