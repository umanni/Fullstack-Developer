import axios from 'axios';

interface UserData {
  first_name?: string;
  last_name?: string;
  email?: string;
  password?: string;
  password_confirmation?: string;
  image?: string;
  profile?: string;
}

export const api = axios.create({
  baseURL: 'http://localhost:3000',
});

// Add a request interceptor
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Add a response interceptor
api.interceptors.response.use(
  (response) => {
    if (response.headers.authorization && !localStorage.getItem('token')) {
      localStorage.setItem('token', response.headers.authorization);
    }
    return response;
  },
  (error) => {
    return Promise.reject(error);
  }
);

export const createUser = async (
  firstName: string,
  lastName: string,
  email: string,
  password: string,
  password_confirmation: string,
  profile?: string
) => {
  return await api.post('/auth/v1/user', {
    first_name: firstName,
    last_name: lastName,
    email,
    password,
    password_confirmation,
    profile,
  });
};

export const loginUser = async (email: string, password: string) => {
  const response = await api.post('/auth/v1/user/sign_in', {
    email,
    password,
  });
  return response.data.data;
};

export async function updateUser(userId: number, updatedData: UserData) {
  try {
    const response = await api.put(`/admin/v1/users/${userId}`, updatedData, {
      headers: {
        Authorization: `Bearer ${api.defaults.headers.authorization}`,
      },
    });
    return response.data;
  } catch (error) {
    console.error(error);
  }
}

export const fetchUsers = async () => {
  try {
    const request = await api.get('/admin/v1/users', {
      headers: {
        Authorization: `Bearer ${api.defaults.headers.authorization}`,
      },
    });
    return request.data;
  } catch (error) {
    console.error(error);
  }
};

export const logoutUser = async () => {
  try {
    await api.delete('/auth/v1/user/sign_out');
    localStorage.removeItem('token');
  } catch (error) {
    return Promise.reject(error);
  }
};

export async function deleteUser(userId: number) {
  try {
    const response = await api.delete(`/admin/v1/users/${userId}`);
    return response.data;
  } catch (error) {
    console.error(error);
  }
}

export default api;
