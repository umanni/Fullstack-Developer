import { useUser } from '../../hooks/useUser';
import { loginUser } from '../../lib/api';
import { useNavigate } from 'react-router-dom';
import { Button, Form, Input, Typography, Layout } from 'antd';

const { Content } = Layout;
const { Title } = Typography;

type LoginFormData = {
  email: string;
  password: string;
};

function Home() {
  const { setCurrentUser } = useUser();
  const navigate = useNavigate();

  const handleLogin = async ({ email, password }: LoginFormData) => {
    try {
      const user = await loginUser(email, password);
      if (user !== undefined) {
        setCurrentUser(user);
      }
      if (user.profile === 'client') {
        navigate('/user/profile');
      }
      if (user.profile === 'admin') {
        navigate('/admin/users');
      }
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <Layout>
      <Content style={{ padding: '50px', maxWidth: '800px', margin: '0 auto' }}>
        <div className="container">
          <Title>Welcome visitor</Title>
          <Form name="basic" onFinish={handleLogin} autoComplete="on">
            <Form.Item
              label="Email"
              name="email"
              rules={[
                { required: true, message: 'Please input your username!' },
              ]}
            >
              <Input />
            </Form.Item>

            <Form.Item
              label="Password"
              name="password"
              rules={[
                { required: true, message: 'Please input your password!' },
              ]}
            >
              <Input.Password />
            </Form.Item>

            <Form.Item wrapperCol={{ offset: 8, span: 16 }}>
              <Button type="primary" htmlType="submit">
                Submit
              </Button>
              <Button type="link" onClick={() => navigate('/register')}>
                Register
              </Button>
            </Form.Item>
          </Form>
        </div>
      </Content>
    </Layout>
  );
}

export default Home;
