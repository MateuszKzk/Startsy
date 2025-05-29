import { ref } from 'vue';
import { api } from 'boot/axios';

// In auth-store.js
export const useAuthStore = () => {
  const user = ref(null);
  const isInitialized = ref(false);

  const initialize = async () => {
    try {
      const response = await api.get('/api/me');
      user.value = response.data.user; // Make sure this sets the .value
      isInitialized.value = true;
      console.log('User initialized:', user.value); // Debug
    } catch (err) {
      console.error('Auth error:', err);
      user.value = null;
      isInitialized.value = true;
    }
  };

  return {
    user, // This is a ref that needs .value access
    isInitialized,
    initialize
  };
};