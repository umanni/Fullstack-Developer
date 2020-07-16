import React, { createContext, useCallback, useState, useContext } from "react";
import { useHistory } from "react-router-dom";

import { message } from "antd";

import api from "../services/api";

interface User {
  id: string;
  full_name: string;
  email: string;
  admin: boolean;
  avatar_image: string;
}

interface AuthState {
  token: string;
  user: User;
}

interface SignInCredentials {
  email: string;
  password: string;
}

interface AuthContextData {
  user: User;
  signIn(credentials: SignInCredentials): Promise<void>;
  signOut(): void;
  updateUser(user: User): void;
  checkProfileUser(): void;
}

const AuthContext = createContext<AuthContextData>({} as AuthContextData);

const AuthProvider: React.FC = ({ children }) => {
  const history = useHistory();

  const [data, setData] = useState<AuthState>(() => {
    const token = localStorage.getItem("@Auth:token");
    const user = localStorage.getItem("@Auth:user");

    if (token && user) {
      api.defaults.headers.Authorization = `Bearer ${token}`;

      return { token, user: JSON.parse(user) };
    }

    return {} as AuthState;
  });

  const signIn = useCallback(async ({ email, password }) => {
    const response = await api.post("user_token", {
      auth: {
        email,
        password,
      },
    });

    const { jwt } = response.data;
    const token = jwt;
    api.defaults.headers.Authorization = `Bearer ${jwt}`;
    localStorage.setItem("@Auth:token", jwt);

    const responseUser = await api.get("users/current");
    const user = responseUser.data;
    localStorage.setItem("@Auth:user", JSON.stringify(user));

    message.success("Login successfully!");

    setData({ token, user });
  }, []);

  const signOut = useCallback(() => {
    localStorage.removeItem("@Auth:token");
    localStorage.removeItem("@Auth:user");

    message.success("Logout successfully!");

    setData({} as AuthState);
  }, []);

  const updateUser = useCallback(
    (user: User) => {
      localStorage.setItem("@Auth:user", JSON.stringify(user));

      setData({
        token: data.token,
        user,
      } as AuthState);
    },
    [data.token]
  );

  const checkProfileUser = useCallback(() => {
    if (data.user.admin) {
      history.push("/dashboard");
    } else {
      history.push("/profile");
    }
  }, [data]);

  return (
    <AuthContext.Provider
      value={{
        user: data.user,
        signIn,
        signOut,
        updateUser,
        checkProfileUser,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

function useAuth(): AuthContextData {
  const context = useContext(AuthContext);

  if (!context) {
    throw new Error("useAuth must be used within an AuthProvider");
  }

  return context;
}

export { AuthProvider, useAuth };
