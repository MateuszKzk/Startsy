import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:5000',
  withCredentials: true // Wichtig für Cookies
});

// Response Interceptor für globale Fehlerbehandlung
api.interceptors.response.use(
  response => response,
  error => {
    if (error.response?.status === 403) {
      // Token ist ungültig - zum Login weiterleiten
      window.location.href = '/login?session=expired';
    }
    return Promise.reject(error);
  }
);

export { api };