<template>
  <q-layout view="lHh Lpr lFf">
    <!-- Header -->
    <q-header elevated class="bg-primary">
      <q-toolbar>
        <q-toolbar-title class="text-white">Startsy</q-toolbar-title>
      </q-toolbar>
    </q-header>

    <!-- Page Container -->
    <q-page-container>
      <q-page class="flex flex-center q-pa-md">
        <div class="background" :class="{ blurred: isBlurred }"></div>

        <q-card class="q-pa-md card-style" :class="{'q-mt-md': isMobile}">
          <q-card-section>
            <h2 class="text-h5 text-white text-center">Login</h2>
          </q-card-section>
          
          <q-card-section>
            <q-form @submit.prevent="login">
              <q-input
                v-model="username"
                label="Username"
                dark
                color="white"
                class="q-mb-sm"
                required
                @focusin="toggleBlur(true)"
                @focusout="toggleBlur(false)"
                dense
                :class="{'q-mb-md': isMobile}"
              />
              <q-input
                v-model="password"
                label="Password"
                type="password"
                dark
                color="white"
                class="q-mb-sm"
                required
                @focusin="toggleBlur(true)"
                @focusout="toggleBlur(false)"
                dense
              />
              <q-btn type="submit" class="modern-btn full-width q-mt-sm" label="Login" />
            </q-form>
            
            <div class="auth-links q-mt-sm">
              <q-btn flat label="Forgot your password?" class="text-button" @click="forgotPassword" />
              <q-btn flat label="Don't have an account?" class="text-button" @click="goToRegister" />
            </div>
          </q-card-section>
        </q-card>
      </q-page>
    </q-page-container>
  </q-layout>
</template>

<script>
import axios from 'axios';
import { useQuasar } from 'quasar';
import { ref } from 'vue';
import { useRouter } from 'vue-router';

export default {
  setup() {
    const $q = useQuasar();
    const router = useRouter();
    const username = ref('');
    const password = ref('');
    const isBlurred = ref(false);
    const isMobile = $q.screen.lt.md;

    const login = async () => {
      try {
        const response = await axios.post('http://localhost:5000/login', {
          username: username.value,
          password: password.value,
        });
        const token = response.data.token;
        localStorage.setItem('auth_token', token);
        localStorage.setItem('user', JSON.stringify(response.data.user));

        axios.defaults.headers['Authorization'] = `Bearer ${token}`;
        
        $q.notify({
          type: 'positive',
          message: 'Login successful!',
          position: 'top',
        });

        router.push({name: 'home'});
      } catch (error) {
        const errorMessage = error.response?.data?.message || 'Login failed. Please try again.';
        $q.notify({
          type: 'negative',
          message: errorMessage,
          position: 'top',
        });
      }
    };

    const forgotPassword = () => {
      router.push('/forgot-password');
    };

    const goToRegister = () => {
      router.push('/register');
    };

    const toggleBlur = (isFocused) => {
      isBlurred.value = isFocused;
    };

    return {
      username,
      password,
      isBlurred,
      isMobile,
      login,
      forgotPassword,
      goToRegister,
      toggleBlur,
    };
  },
};
</script>

<style scoped>
.card-style {
  width: 100%;
  max-width: 400px;
  background: rgba(0, 0, 0, 0.7);
  backdrop-filter: blur(5px);
  border-radius: 10px;
}

.background {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: url('/images/wp12482965.jpg') no-repeat center center;
  background-size: cover;
  transition: filter 0.3s ease;
}

.background.blurred {
  filter: blur(5px);
}

.modern-btn {
  background: linear-gradient(45deg, #2196F3, #00BCD4);
  color: white;
  border: none;
  border-radius: 5px;
  padding: 10px;
  font-weight: bold;
}

.text-button {
  color: #2196F3 !important;
}

.auth-links {
  display: flex;
  justify-content: space-between;
}

@media (max-width: 600px) {
  .card-style {
    max-width: 100%;
    padding: 20px;
  }
}
</style>
