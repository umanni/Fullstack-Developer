import React, { createContext, useState, useContext, ReactNode } from 'react';

interface UserProviderProps {
  children: ReactNode;
}

type User = {
  id: number;
  first_name: string;
  last_name: string;
  email: string;
  profile: string;
  image: string;
};

interface UserContextProps {
  currentUser: User | undefined;
  setCurrentUser?: React.Dispatch<React.SetStateAction<User | undefined>>;
}

export const UserContext = createContext<UserContextProps>({
  currentUser: undefined,
});

export function UserProvider({ children }: UserProviderProps) {
  const [currentUser, setCurrentUser] = useState<User | undefined>();

  const value: UserContextProps = {
    currentUser: currentUser,
    setCurrentUser: setCurrentUser,
  };

  return <UserContext.Provider value={value}>{children}</UserContext.Provider>;
}

export function useUser() {
  const context = useContext(UserContext);

  return context;
}
