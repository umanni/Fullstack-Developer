import { useNavigate } from 'react-router-dom';
import { logoutUser } from '../../../lib/api';
import { Button } from 'antd';
import { useUser } from '../../../hooks/useUser';
import Layout, { Content } from 'antd/es/layout/layout';
import UserForm from '../../../components/Admin/UserForm/index';
import './styles.scss';

export function LoggedAdmin() {
  const { currentUser, setCurrentUser } = useUser();
  const navigate = useNavigate();

  async function handleLogout() {
    try {
      await logoutUser();
      // eslint-disable-next-line @typescript-eslint/ban-ts-comment
      // @ts-ignore
      setCurrentUser(undefined);
      navigate('/');
    } catch (err) {
      console.error(err);
    }
  }

  return (
    <Layout>
      <Content>
        <div className="adminForm">
          <h1 className='title'>
            Welcome Admin {currentUser?.first_name} {currentUser?.last_name}
          </h1>
          <Button className='logoutButton' type="primary" danger onClick={handleLogout}>
            Logout
          </Button>
        </div>
        <UserForm />
      </Content>
    </Layout>
  );
}
