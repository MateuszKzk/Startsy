<template>
  <q-layout view="lHh Lpr lFf">
    <q-page-container>
      <q-page class="flex flex-center bg-animated">
        <!-- Animated Background -->
        <div class="animated-bubbles">
          <div v-for="i in 15" :key="i" class="bubble" :style="bubbleStyle(i)"></div>
        </div>

        <!-- Register Card -->
        <q-card class="login-card q-pa-lg shadow-10">
          <q-card-section class="text-center">
            <q-avatar size="80px" class="q-mb-sm">
              <img src="~assets/quasar-logo-vertical.svg">
            </q-avatar>
            <h4 class="text-h5 text-weight-bold q-mt-sm text-white">Register at Startsy</h4>
          </q-card-section>

          <q-card-section>
            <q-form @submit.prevent="register" class="q-gutter-md">
              <!-- Full Name -->
              <q-input
                v-model="full_name"
                label="Full Name"
                outlined
                dark
                color="white"
                :rules="[val => !!val || 'Field is required']"
              >
                <template v-slot:prepend>
                  <q-icon name="badge" color="white" />
                </template>
              </q-input>

              <!-- Role Dropdown - Verbessert -->
              <q-select
                v-model="role"
                :options="roleOptions"
                label="Role"
                outlined
                dark
                color="white"
                :rules="[val => !!val || 'Field is required']"
                class="animated-select"
                menu-class="animated-menu"
                behavior="menu"
              >
                <template v-slot:prepend>
                  <q-icon name="work" color="white" />
                </template>
              </q-select>

              <!-- Username -->
              <q-input
                v-model="username"
                label="Username"
                outlined
                dark
                color="white"
                :rules="[val => !!val || 'Field is required']"
              >
                <template v-slot:prepend>
                  <q-icon name="person" color="white" />
                </template>
              </q-input>

              <!-- Password -->
              <q-input
                v-model="password"
                label="Password"
                type="password"
                outlined
                dark
                color="white"
                :rules="[val => !!val || 'Field is required']"
              >
                <template v-slot:prepend>
                  <q-icon name="lock" color="white" />
                </template>
              </q-input>

              <!-- Confirm Password -->
              <q-input
                v-model="confirmPassword"
                label="Confirm Password"
                type="password"
                outlined
                dark
                color="white"
                :rules="[
                  val => !!val || 'Field is required',
                  val => val === password || 'Passwords do not match'
                ]"
              >
                <template v-slot:prepend>
                  <q-icon name="lock" color="white" />
                </template>
              </q-input>

              <!-- Submit Button -->
              <div>
                <q-btn
                  type="submit"
                  label="Register"
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
              label="Already have an account?"
              class="text-button"
              @click="goToLogin"
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
  name: 'RegisterPage',
  setup() {
    const $q = useQuasar();
    const router = useRouter();
    const full_name = ref('');
    const username = ref('');
    const password = ref('');
    const confirmPassword = ref('');
    const role = ref('');
    const roleOptions = ['Mitstreiter', 'Gründer'];
    const loading = ref(false);

    const register = async () => {
      loading.value = true;
      try {
        await axios.post('http://localhost:5000/register', {
          full_name: full_name.value,
          username: username.value,
          password: password.value,
          role: role.value
        });

        $q.notify({
          type: 'positive',
          message: 'Registration successful! Please login.',
          position: 'top',
        });

        router.push('/login');
      } catch (error) {
        const errorMessage = error.response?.data?.message || 'Registration failed. Please try again.';
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

    const goToLogin = () => {
      router.push('/login');
    };

    return {
      full_name,
      username,
      password,
      confirmPassword,
      role,
      roleOptions,
      loading,
      register,
      bubbleStyle,
      goToLogin
    };
  }
};
</script>

<style scoped>
/* Identische Styles wie in LoginPage.vue */
.login-card {
  width: 100%;
  max-width: 420px; /* Etwas breiter wegen mehr Feldern */
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

@media (max-width: 600px) {
  .login-card {
    max-width: 100%;
    padding: 20px;
  }
}

.animated-select {
  transition: all 0.3s ease;
}

.animated-select:hover {
  transform: translateY(-2px);
}

:deep(.animated-menu) {
  background: rgba(0, 0, 0, 0.85);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  margin-top: 5px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
  animation: float 6s ease-in-out infinite;
}

:deep(.q-item) {
  color: white;
  transition: all 0.2s ease;
}

:deep(.q-item:hover) {
  background: rgba(255, 255, 255, 0.1);
  transform: translateX(5px);
}

:deep(.q-item__label) {
  font-weight: 500;
}
</style>