<template>
  <q-layout view="lHh Lpr lFf">
    <q-page-container>
      <q-page class="flex flex-center bg-animated">
        <!-- Animated Background -->
        <div class="animated-bubbles">
          <div v-for="i in 15" :key="i" class="bubble" :style="bubbleStyle(i)"></div>
        </div>

        <!-- Login Card mit Ihren bestehenden Funktionen -->
        <q-card class="login-card q-pa-lg shadow-10">
          <q-card-section class="text-center">
            <q-avatar size="80px" class="q-mb-sm">
              <img src="~assets/quasar-logo-vertical.svg">
            </q-avatar>
            <h4 class="text-h5 text-weight-bold q-mt-sm text-white">Login to Startsy</h4>
          </q-card-section>

          <q-card-section>
            <q-form @submit.prevent="login" class="q-gutter-md">
              <q-input
                v-model="username"
                label="Username"
                outlined
                dark
                color="white"
                :rules="[val => !!val || 'Field is required']"
                @focusin="toggleBlur(true)"
                @focusout="toggleBlur(false)"
              >
                <template v-slot:prepend>
                  <q-icon name="person" color="white" />
                </template>
              </q-input>

              <q-input
                v-model="password"
                label="Password"
                type="password"
                outlined
                dark
                color="white"
                :rules="[val => !!val || 'Field is required']"
                @focusin="toggleBlur(true)"
                @focusout="toggleBlur(false)"
              >
                <template v-slot:prepend>
                  <q-icon name="lock" color="white" />
                </template>
              </q-input>

              <div>
                <q-btn
                  type="submit"
                  label="Login"
                  color="primary"
                  class="full-width modern-btn"
                  size="lg"
                  :loading="loading"
                />
              </div>
            </q-form>
          </q-card-section>

          <q-card-actions class="q-px-md">
            <q-btn
              flat
              label="Forgot password?"
              class="text-button"
              @click="forgotPassword"
            />
            <q-space />
            <q-btn
              flat
              label="Create account"
              class="text-button"
              @click="goToRegister"
            />
          </q-card-actions>
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
  name: 'LoginPage',
  setup() {
    const $q = useQuasar();
    const router = useRouter();
    const username = ref('');
    const password = ref('');
    const isBlurred = ref(false);
    const loading = ref(false);
    const isMobile = $q.screen.lt.md;

    const login = async () => {
  loading.value = true;
  try {
    const response = await axios.post('http://localhost:5000/login', {
      username: username.value,
      password: password.value,
    });
    
    if (!response.data.token) {
      throw new Error('No token received');
    }
    
    const token = response.data.token;
    localStorage.setItem('auth_token', token);
    localStorage.setItem('user', JSON.stringify(response.data.user));

    axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
    
    $q.notify({
      type: 'positive',
      message: 'Login successful!',
      position: 'top',
    });

    router.push({name: 'dashboard'});
  } catch (error) {
    let errorMessage = 'Login failed. Please try again.';
    if (error.response) {
      errorMessage = error.response.data?.message || errorMessage;
    } else if (error.request) {
      errorMessage = 'No response from server';
    }
    
    $q.notify({
      type: 'negative',
      message: errorMessage,
      position: 'top',
    });
  } finally {
    loading.value = false;
  }
};

    const bubbleStyle = () => {
      const size = Math.random() * 20 + 10;
      return {
        width: `${size}px`,
        height: `${size}px`,
        left: `${Math.random() * 100}%`,
        animationDelay: `${Math.random() * 5}s`,
        animationDuration: `${Math.random() * 20 + 10}s`,
        opacity: Math.random() * 0.5 + 0.1
      };
    };

    const toggleBlur = (isFocused) => {
      isBlurred.value = isFocused;
    };

    return {
      username,
      password,
      isBlurred,
      loading,
      isMobile,
      login,
      bubbleStyle,
      toggleBlur,
      forgotPassword: () => router.push('/forgot-password'),
      goToRegister: () => router.push('/register')
    };
  }
};
</script>

<style scoped>
.login-card {
  width: 100%;
  max-width: 380px;
  border-radius: 12px;
  z-index: 1;
  background: rgba(0, 0, 0, 0.7);
  backdrop-filter: blur(5px);
  animation: float 6s ease-in-out infinite;
}

.bg-animated {
  background: linear-gradient(135deg, #1a237e 0%, #283593 50%, #3949ab 100%);
  position: relative;
  overflow: hidden;
}

.animated-bubbles {
  position: absolute;
  width: 100%;
  height: 100%;
  overflow: hidden;
  top: 0;
  left: 0;
}

.bubble {
  position: absolute;
  bottom: -100px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 50%;
  animation: rise 15s infinite ease-in;
}

.bubble:nth-child(odd) {
  background: rgba(255, 255, 255, 0.15);
}

@keyframes rise {
  0% {
    bottom: -100px;
    transform: translateX(0);
  }
  50% {
    transform: translateX(100px);
  }
  100% {
    bottom: 100%;
    transform: translateX(-200px);
  }
}

@keyframes float {
  0% { transform: translateY(0px); }
  50% { transform: translateY(-15px); }
  100% { transform: translateY(0px); }
}

.modern-btn {
  background: linear-gradient(45deg, #2196F3, #00BCD4);
  color: white;
  border: none;
  border-radius: 5px;
  font-weight: bold;
}

.text-button {
  color: #2196F3 !important;
}

/* Blur-Effekt für den Hintergrund */
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

@media (max-width: 600px) {
  .login-card {
    max-width: 100%;
    padding: 20px;
  }
}
</style>