import axios from 'axios';
import { csrfToken } from 'rails-ujs'

axios.defaults.headers.common['X-CSRF-Token'] = csrfToken();

const api = axios.create({
  baseURL: 'http://localhost:3333/api',
});

export default api;