<template>
  <q-page class="flex flex-center" style="overflow: hidden; position: relative;">
    <div class="background" :class="{ blurred: isBlurred }"></div>

    <transition name="fade" mode="out-in">
      <q-card v-if="step === 1" class="q-pa-md card-style">
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
              @focusin="toggleBlur(true)"
              @focusout="toggleBlur(false)"
              :rules="[val => val === password || 'Passwords do not match']"
              bottom-slots
              :error="password !== confirmPassword"
              error-message="Passwords do not match"
            />
           
            <q-btn type="submit" class="modern-btn full-width q-mt-sm" label="Register" />
          </q-form>
          <div class="auth-links">
            <q-btn flat label="Forgot your password?" class="text-button" @click="forgotPassword" />
            <q-btn flat label="Already have an account?" class="text-button" @click="goToLogin" />
          </div>
        </q-card-section>
      </q-card>
    </transition>
  </q-page>
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
    const step = ref(1);
    const full_name = ref('');
    const username = ref('');
    const password = ref('');
    const confirmPassword = ref('');
    const role = ref('');
    const roleOptions = ['Mitstreiter', 'Gründer'];
    const isBlurred = ref(false);

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
    localStorage.setItem('auth_token', token); // <--- Token speichern

    $q.notify({
      type: 'positive',
      message: 'Registration successful! Redirecting...',
      position: 'top',
    });

    setTimeout(() => {
      router.push({ name: 'home' });
    }, 1500);
  } catch (error) {
    const errorMessage = error.response?.data?.message || 'Registration failed. Please try again.';
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

    const goToLogin = () => {
      router.push('/login');
    };

    const toggleBlur = (isFocused) => {
      isBlurred.value = isFocused;
    };

    return {
      step,
      full_name,
      username,
      password,
      confirmPassword,
      role,
      roleOptions,
      isBlurred,
      register,
      forgotPassword,
      goToLogin,
      toggleBlur
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
  margin-top: 20px;
}
</style>