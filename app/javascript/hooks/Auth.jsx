/* eslint-disable react/prop-types */
import React, { createContext, useCallback, useState, useContext } from 'react';

import api from '../services/api';

const AuthContext = createContext();

const AuthProvider = ({ children }) => {
  const [data, setData] = useState(() => {
    const id = JSON.parse(localStorage.getItem('@FullstackDeveloper:id'));
    const admin = JSON.parse(localStorage.getItem('@FullstackDeveloper:admin'));

    if (id) {
      return {
        id,
        admin,
      };
    }

    return {};
  });

  const signIn = useCallback(async ({ email, password }) => {
    const response = await api.post('users/sign_in', {
      user: {
        email,
        password,
      },
    });

    const { id, admin } = response.data;

    if (id !== undefined) {
      localStorage.setItem('@FullstackDeveloper:id', JSON.stringify(id));
      localStorage.setItem('@FullstackDeveloper:admin', JSON.stringify(admin));

      setData({ id, admin });
    }
  }, []);

  const signOut = useCallback(() => {
    localStorage.removeItem('@FullstackDeveloper:id');
    localStorage.removeItem('@FullstackDeveloper:admin');

    setData({});
  }, []);

  return (
    <AuthContext.Provider
      value={{ id: data.id, admin: data.admin, signIn, signOut }}
    >
      {children}
    </AuthContext.Provider>
  );
};

function useAuth() {
  const context = useContext(AuthContext);

  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider!');
  }

  return context;
}

export { AuthProvider, useAuth };
