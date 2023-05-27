import { useUser } from '../../hooks/useUser';
import { loginUser } from '../../lib/api';
import { useNavigate } from 'react-router-dom';
import { Button, Form, Input, Typography, Layout } from 'antd';
import './styles.scss';

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
      if (user !== undefined && setCurrentUser) {
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
      <Content className="homeContainer">
        <Title>Welcome visitor</Title>

        <Form
          className="form"
          name="basic"
          onFinish={handleLogin}
          autoComplete="on"
        >
          <Form.Item
            className="textForm"
            label="Email"
            name="email"
            rules={[{ required: true, message: 'Please input your username!' }]}
          >
            <Input />
          </Form.Item>

          <Form.Item
            label="Password"
            name="password"
            rules={[{ required: true, message: 'Please input your password!' }]}
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
      </Content>
    </Layout>
  );
}

export default Home;
