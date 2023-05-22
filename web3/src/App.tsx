import {
  BrowserRouter as Router,
  Route,
  Routes,
  Navigate,
} from 'react-router-dom';
import { UserProvider, useUser } from './hooks/useUser';
import ProfilePage from './pages/Auth/ProfilePage';
import { LoggedAdmin } from './pages/Auth/LoggedAdmin';
import Home from './pages/Home';
import RegisterPage from './components/Register';
import 'antd/dist/reset.css';
import './App.scss';

function App() {
  const { currentUser } = useUser();

  return (
    <UserProvider>
      <Router>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/register" element={<RegisterPage />} />
          <Route path="/user/profile" element={<ProfilePage />} />
          {/* {!currentUser && (
            <Route path="/user/profile" element={<Navigate to="/" replace />} />
          )} */}
          <Route path="/admin/users/" element={<LoggedAdmin />} />
        </Routes>
      </Router>
    </UserProvider>
  );
}

export default App;
