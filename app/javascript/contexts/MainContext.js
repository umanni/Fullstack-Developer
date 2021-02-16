import React, {useState, useEffect, createContext} from 'react';

import Api from '@/services/api';

export const MainContext = createContext({});

export default function MainProvider({children}){
  const [currentUser, setCurrentUser] = useState({
    id: 0,
    full_name: '',
    email: '',
    avatar_image: '',
    admin: false,
    created_at: '',
  });

  useEffect(() => {
    Api.get('api/main')
    .then(response => {
      const {current_user} = response.data;
      setCurrentUser(current_user);
    });
  }, []);

  return (
    <MainContext.Provider value={{currentUser}}>{children}</MainContext.Provider>
  );
}
