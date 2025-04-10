<template>
  <q-layout view="lHh Lpr lFf">
    <q-header elevated class="bg-primary">
      <q-toolbar>
        <q-toolbar-title class="text-white">Startsy</q-toolbar-title>
      </q-toolbar>
    </q-header>

    <q-page-container>
      <q-page class="flex flex-center q-pa-md">
        <div class="background" :class="{ blurred: isBlurred }"></div>

        <q-card class="q-pa-md card-style" :class="{ 'q-mt-md': isMobile }">
          <q-card-section>
            <h2 class="text-h5 text-white text-center">Register</h2>
          </q-card-section>

          <q-card-section>
            <q-form @submit.prevent="register">
              <q-input
                v-model="full_name"
                label="Full Name"
                dark
                color="white"
                class="q-mb-sm"
                required
                dense
                @focusin="toggleBlur(true)"
                @focusout="toggleBlur(false)"
              />

              <q-select
                v-model="role"
                :options="roleOptions"
                label="Role"
                dark
                color="white"
                class="q-mb-sm"
                required
                dense
                @focusin="toggleBlur(true)"
                @focusout="toggleBlur(false)"
              />

              <q-input
                v-model="username"
                label="Username"
                dark
                color="white"
                class="q-mb-sm"
                required
                dense
                @focusin="toggleBlur(true)"
                @focusout="toggleBlur(false)"
              />

              <q-input
                v-model="password"
                label="Password"
                type="password"
                dark
                color="white"
                class="q-mb-sm"
                required
                dense
                @focusin="toggleBlur(true)"
                @focusout="toggleBlur(false)"
              />

              <q-input
                v-model="confirmPassword"
                label="Confirm Password"
                type="password"
                dark
                color="white"
                class="q-mb-sm"
                required
                dense
                :rules="[val => val === password || 'Passwords do not match']"
                @focusin="toggleBlur(true)"
                @focusout="toggleBlur(false)"
              />

              <q-btn type="submit" class="modern-btn full-width q-mt-sm" label="Register" />
            </q-form>

            <div class="auth-links q-mt-sm">
              <q-btn flat label="Already have an account?" class="text-button" @click="goToLogin" />
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
    const full_name = ref('');
    const username = ref('');
    const password = ref('');
    const confirmPassword = ref('');
    const role = ref('');
    const roleOptions = ['Mitstreiter', 'Gründer'];
    const isBlurred = ref(false);
    const isMobile = $q.screen.lt.md;

    const register = async () => {
      if (password.value !== confirmPassword.value) {
        $q.notify({
          type: 'negative',
          message: 'Passwords do not match. Please try again.',
          position: 'top',
        });
        return;
      }

      try {
        const response = await axios.post('http://localhost:5000/register', {
          full_name: full_name.value,
          username: username.value,
          password: password.value,
          role: role.value
        });

        const token = response.data.token;
        localStorage.setItem('auth_token', token);

        $q.notify({
          type: 'positive',
          message: 'Account created successfully!',
          position: 'top',
        });

        router.push('/login');
      } catch (error) {
        const errorMessage = error.response?.data?.message || 'Registration failed.';
        $q.notify({
          type: 'negative',
          message: errorMessage,
          position: 'top',
        });
      }
    };

    const goToLogin = () => {
      router.push('/login');
    };

    const toggleBlur = (isFocused) => {
      isBlurred.value = isFocused;
    };

    return {
      full_name,
      username,
      password,
      confirmPassword,
      role,
      roleOptions,
      isBlurred,
      isMobile,
      register,
      goToLogin,
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
  z-index: -1;
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
  justify-content: center;
}

@media (max-width: 600px) {
  .card-style {
    max-width: 100%;
    padding: 20px;
  }
}
</style>
