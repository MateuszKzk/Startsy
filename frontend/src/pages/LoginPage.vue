<template>
  <q-page class="flex flex-center" style="overflow: hidden; position: relative;">
    <div class="background" :class="{ blurred: isBlurred }"></div>

    <transition name="fade" mode="out-in">
      <q-card class="q-pa-md card-style">
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
            <q-btn type="submit" class="modern-btn full-width q-mt-sm" label="Login" />
          </q-form>
          <div class="auth-links">
            <q-btn flat label="Forgot your password?" class="text-button" @click="forgotPassword" />
            <q-btn flat label="Don't have an account?" class="text-button" @click="goToRegister" />
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

import '../css/style.scss';

export default {
  setup() {
    const $q = useQuasar();
    const router = useRouter();
    const username = ref('');
    const password = ref('');
    const isBlurred = ref(false);

    // Login-Funktion
    const login = async () => {
      try {
        // Anfrage zum Backend
        const response = await axios.post('http://localhost:5000/login', {
          username: username.value,
          password: password.value,
        });

        // Angenommene Antwort enthält das JWT-Token
        const token = response.data.token;
        
        // Speichern des Tokens im localStorage
        localStorage.setItem('auth_token', token);
       localStorage.setItem('user', JSON.stringify(response.data.user));

        // Setze den Authorization-Header für Axios-Anfragen
        axios.defaults.headers['Authorization'] = `Bearer ${token}`;

        // Erfolgreiches Login Feedback
        $q.notify({
          type: 'positive',
          message: 'Login successful!',
          position: 'top',
        });

        // Weiterleitung zur Startseite
        router.push({name: 'home'});
      } catch (error) {
        if (error.response && error.response.data) {
          // Detaillierte Fehlermeldung aus der Antwort
          const errorMessage = error.response.data.message || 'Login failed. Please try again.';
          
          $q.notify({
            type: 'negative',
            message: errorMessage,  // Fehlermeldung vom Backend anzeigen
            position: 'top',
          });
        } else {
          // Allgemeiner Fehler, wenn die Antwort nicht den erwarteten Inhalt hat
          $q.notify({
            type: 'negative',
            message: 'An error occurred. Please try again later.',
            position: 'top',
          });
        }
      }
    };

    // Weiterleitung zur "Passwort vergessen"-Seite
    const forgotPassword = () => {
      router.push('/forgot-password');
    };

    // Weiterleitung zur Registrierungsseite
    const goToRegister = () => {
      router.push('/register');
    };

    // Blurring der Hintergrundbilder bei Eingabe
    const toggleBlur = (isFocused) => {
      isBlurred.value = isFocused;
    };

    return {
      username,
      password,
      isBlurred,
      login,
      forgotPassword,
      goToRegister,
      toggleBlur,
    };
  },
};
</script>

<style scoped>
@import url('../css/style.scss');
</style>
