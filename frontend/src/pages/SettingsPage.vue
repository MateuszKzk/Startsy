<template>
  <q-page class="q-pa-lg">
    <div class="text-h4 q-mb-md">Einstellungen</div>

    <q-card class="q-pa-md">
      <q-list>
        <!-- Dark Mode -->
        <q-item>
          <q-item-section>
            <q-item-label>Dark Mode</q-item-label>
          </q-item-section>
          <q-item-section side>
            <q-toggle
              v-model="isDark"
              @update:model-value="toggleDarkMode"
              color="primary"
              :loading="darkModeLoading"
            />
          </q-item-section>
        </q-item>

        <q-separator class="q-my-sm" />

        <!-- Passwort ändern -->
        <q-item clickable @click="changePassword">
          <q-item-section avatar>
            <q-icon name="lock" color="primary" />
          </q-item-section>
          <q-item-section>
            <q-item-label>Passwort ändern</q-item-label>
          </q-item-section>
        </q-item>

        <!-- Abmelden -->
        <q-item clickable @click="logout">
          <q-item-section avatar>
            <q-icon name="logout" color="negative" />
          </q-item-section>
          <q-item-section>
            <q-item-label class="text-negative">Abmelden</q-item-label>
          </q-item-section>
        </q-item>
      </q-list>
    </q-card>
  </q-page>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useQuasar } from 'quasar'
import { useRouter } from 'vue-router'
import { api } from 'src/boot/axios'

const $q = useQuasar()
const router = useRouter()

const isDark = ref(false)
const darkModeLoading = ref(false)

// Initiale Einstellungen laden
onMounted(async () => {
  try {
    darkModeLoading.value = true
    const response = await api.get('/api/user/settings')

    if (response.data.dark_mode === undefined) {
      isDark.value = $q.dark.isActive
      await api.post('/api/user/settings', { dark_mode: isDark.value })
    } else {
      isDark.value = response.data.dark_mode
      $q.dark.set(isDark.value)
    }
  } catch (err) {
    console.error('Fehler beim Laden der Einstellungen:', err)
    isDark.value = $q.dark.isActive
  } finally {
    darkModeLoading.value = false
  }
})

// Dark Mode umschalten und speichern
const toggleDarkMode = async () => {
  try {
    darkModeLoading.value = true
    $q.dark.toggle()
    isDark.value = $q.dark.isActive

    await api.post('/api/user/settings', { dark_mode: isDark.value })

    $q.notify({
      message: 'Einstellungen gespeichert',
      color: 'positive',
      timeout: 1000
    })
  } catch (err) {
    console.error('Fehler beim Speichern der Einstellungen:', err)
    $q.notify({
      message: 'Einstellungen konnten nicht gespeichert werden',
      color: 'negative'
    })

    $q.dark.toggle() // zurückschalten
    isDark.value = $q.dark.isActive
  } finally {
    darkModeLoading.value = false
  }
}

// Passwort ändern Dialog
const changePassword = () => {
  $q.dialog({
    title: 'Passwort ändern',
    message: 'Bitte geben Sie Ihr aktuelles und neues Passwort ein',
    prompts: [
      {
        model: '',
        type: 'password',
        label: 'Aktuelles Passwort',
        isValid: val => val.length > 0,
        hint: 'Ihr aktuelles Passwort'
      },
      {
        model: '',
        type: 'password',
        label: 'Neues Passwort',
        isValid: val => val.length > 6,
        hint: 'Mindestens 6 Zeichen'
      }
    ],
    cancel: true,
    persistent: true
  }).onOk(async ([currentPassword, newPassword]) => {
    try {
      await api.post('/api/user/change-password', {
        currentPassword,
        newPassword
      })
      $q.notify({
        message: 'Passwort erfolgreich geändert',
        color: 'positive'
      })
    } catch (err) {
      console.error(err)
      $q.notify({
        message: err.response?.data?.message || 'Passwort konnte nicht geändert werden',
        color: 'negative'
      })
    }
  })
}

// Logout mit HTTP-Only Cookie
const logout = () => {
  $q.dialog({
    title: 'Abmelden',
    message: 'Möchten Sie sich wirklich abmelden?',
    cancel: true,
    persistent: true
  }).onOk(async () => {
    try {
      await api.post('/api/logout')  // Cookie wird serverseitig entfernt
      router.push('/login')
      $q.notify({
        message: 'Erfolgreich abgemeldet',
        color: 'positive'
      })
    } catch (err) {
      console.error('Fehler beim Logout:', err)
      $q.notify({
        message: 'Abmelden fehlgeschlagen',
        color: 'negative'
      })
    }
  })
}
</script>
