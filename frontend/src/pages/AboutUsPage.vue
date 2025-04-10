<template>
  <q-page class="q-pa-lg">
    <div class="text-h4 q-mb-md">Über Uns</div>
    <q-card class="q-pa-md">
      <p>Wir sind Startsy - eine Plattform für innovative Startups.</p>
      <p class="q-mt-sm">Gegründet im Jahr 2023 mit der Vision, Gründern die besten Tools bereitzustellen.</p>
      
      <q-list class="q-mt-md">
        <q-item>
          <q-item-section avatar>
            <q-icon name="groups" color="primary"/>
          </q-item-section>
          <q-item-section>
            <q-item-label>Unser Team</q-item-label>
            <q-item-label caption>Erfahren und engagiert</q-item-label>
          </q-item-section>
        </q-item>
        
        <q-item>
          <q-item-section avatar>
            <q-icon name="location_on" color="primary"/>
          </q-item-section>
          <q-item-section>
            <q-item-label>Standort</q-item-label>
            <q-item-label caption>Wien, Österreich</q-item-label>
          </q-item-section>
        </q-item>
      </q-list>
    </q-card>
    
    <div class="text-h6 q-mt-xl">Kontakt</div>
    <q-card class="q-pa-md q-mt-sm">
      <q-form @submit="sendMessage">
        <q-input v-model="message" label="Ihre Nachricht" type="textarea"/>
        <q-btn label="Senden" type="submit" color="primary" class="q-mt-md"/>
      </q-form>
    </q-card>
  </q-page>
</template>

<script>
import { ref } from 'vue'

export default {
  setup() {
    const message = ref('')
    
    const sendMessage = () => {
      alert('Nachricht gesendet!')
      message.value = ''
    }

    return { message, sendMessage }
  }
}
</script>