<template>
    <q-page class="q-pa-lg">
      <div class="text-h4 q-mb-md">Einstellungen</div>
      
      <q-card class="q-pa-md">
        <q-list>
          <q-item>
            <q-item-section>
              <q-item-label>Benachrichtigungen</q-item-label>
            </q-item-section>
            <q-item-section side>
              <q-toggle v-model="notifications" color="primary"/>
            </q-item-section>
          </q-item>
          
          <q-item>
            <q-item-section>
              <q-item-label>Dark Mode</q-item-label>
            </q-item-section>
            <q-item-section side>
              <q-toggle v-model="darkMode" @update:model-value="toggleDarkMode" color="primary"/>
            </q-item-section>
          </q-item>
          
          <q-separator class="q-my-sm"/>
          
          <q-item clickable @click="changePassword">
            <q-item-section avatar>
              <q-icon name="password" color="primary"/>
            </q-item-section>
            <q-item-section>
              <q-item-label>Passwort ändern</q-item-label>
            </q-item-section>
          </q-item>
          
          <q-item clickable @click="logout">
            <q-item-section avatar>
              <q-icon name="logout" color="negative"/>
            </q-item-section>
            <q-item-section>
              <q-item-label class="text-negative">Abmelden</q-item-label>
            </q-item-section>
          </q-item>
        </q-list>
      </q-card>
    </q-page>
  </template>
  
  <script>
  import { ref } from 'vue'
  import { useQuasar } from 'quasar'
  import { useRouter } from 'vue-router'
  
  export default {
    setup() {
      const $q = useQuasar()
      const router = useRouter()
      
      const notifications = ref(true)
      const darkMode = ref($q.dark.isActive)
      
      const toggleDarkMode = () => {
        $q.dark.toggle()
      }
      
      const changePassword = () => {
        $q.dialog({
          title: 'Passwort ändern',
          message: 'Hier könnten Sie Ihr Passwort ändern',
          cancel: true
        })
      }
      
      const logout = () => {
        $q.dialog({
          title: 'Abmelden',
          message: 'Möchten Sie sich wirklich abmelden?',
          cancel: true,
          persistent: true
        }).onOk(() => {
          router.push('/login')
        })
      }
  
      return { notifications, darkMode, toggleDarkMode, changePassword, logout }
    }
  }
  </script>