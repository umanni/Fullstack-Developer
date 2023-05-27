import { useNavigate } from 'react-router-dom';
import { logoutUser } from '../../../lib/api';
import { Button } from 'antd';
import { useUser } from '../../../hooks/useUser';
import Layout, { Content, Header } from 'antd/es/layout/layout';
import UserForm from '../../../components/Admin/UserForm/index';
import './styles.scss';
import { useEffect } from 'react';
import Title from 'antd/es/typography/Title';

export function LoggedAdmin() {
  const { currentUser, setCurrentUser } = useUser();
  const navigate = useNavigate();

  async function handleLogout() {
    try {
      await logoutUser();
      if (setCurrentUser) {
        setCurrentUser(undefined);
      }
      navigate('/');
    } catch (err) {
      console.error(err);
    }
  }

  // useEffect(() => {
  //   if (currentUser?.profile !== 'admin') {
  //     navigate('/user/profile', { user: currentUser });
  //   }
  // }, [currentUser, navigate]);

  return (
    <Layout>
      <Content>
        <Header className='header'>
          <Title level={2} className="title">
            Welcome Admin {currentUser?.first_name} {currentUser?.last_name}
          </Title>
          <Button
            className="logoutButton"
            type="primary"
            danger
            onClick={handleLogout}
          >
            Logout
          </Button>
        </Header>
        <div className="adminForm"></div>
        <UserForm />
      </Content>
    </Layout>
  );
}
