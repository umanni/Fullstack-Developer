import React, {useState, useEffect, createContext, useCallback} from 'react';

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
  const [currentPosition, setCurrentPosition] = useState('/');

  useEffect(() => {
    Api.get('api/main')
    .then(response => {
      const {current_user} = response.data;
      setCurrentUser(current_user);
    });
  }, []);

  const updateValue = useCallback((user) => {
    setCurrentUser(user);
  });

  const setMyPosition = useCallback((position) => {
    setCurrentPosition(position);
  });

  return (
    <MainContext.Provider value={{currentUser, updateValue, currentPosition, setMyPosition}}>
      {children}
    </MainContext.Provider>
  );
}
