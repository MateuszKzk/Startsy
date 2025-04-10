<template>
    <q-page class="flex flex-center">
      <div class="q-pa-md text-center">
        <q-img
          src="~assets/quasar-logo-full.svg"
          style="width: 200px; height: 200px"
        />
  
        <div class="text-h4 q-mt-md">Willkommen bei Startsy</div>
        <div class="text-subtitle1 q-mt-sm">
          Ihre Plattform für Startup-Innovationen
        </div>
  
        <div class="q-mt-lg">
          <q-btn
            color="primary"
            label="Loslegen"
            :to="{ name: 'register' }"
          />
          <q-btn
            class="q-ml-sm"
            color="secondary"
            label="Mehr erfahren"
            outline
            @click="scrollToFeatures"
          />
        </div>
      </div>
    </q-page>
  </template>
  
  <script>
  import { defineComponent } from 'vue'
  
  export default defineComponent({
    name: 'IndexPage',
    setup() {
      const scrollToFeatures = () => {
        console.log('Scroll to features')
        // Implementieren Sie die Scroll-Logik hier
      }
  
      return {
        scrollToFeatures
      }
    }
  })
  </script>