<template>
    <q-page class="q-pa-lg">
      <div class="row items-center justify-between q-mb-md">
        <div class="text-h4">Meine Startups</div>
        <q-btn label="Neues Startup" color="primary" @click="addStartup"/>
      </div>
      
      <div v-if="startups.length === 0" class="text-center q-pa-xl">
        <q-icon name="business" size="xl" color="grey-5"/>
        <div class="text-h6 q-mt-sm">Noch keine Startups</div>
        <q-btn label="Erstes Startup hinzufügen" color="primary" outline class="q-mt-md"/>
      </div>
      
      <div v-else class="row q-col-gutter-md">
        <div v-for="startup in startups" :key="startup.id" class="col-12 col-md-6">
          <q-card>
            <q-img :src="startup.image" height="150px">
              <div class="absolute-bottom text-h6">{{ startup.name }}</div>
            </q-img>
            
            <q-card-section>
              <div>{{ startup.description }}</div>
              <q-chip v-for="tag in startup.tags" :key="tag" color="primary" text-color="white" class="q-mr-sm q-mt-sm">
                {{ tag }}
              </q-chip>
            </q-card-section>
            
            <q-card-actions align="right">
              <q-btn flat label="Bearbeiten" color="primary"/>
              <q-btn flat label="Löschen" color="negative"/>
            </q-card-actions>
          </q-card>
        </div>
      </div>
    </q-page>
  </template>
  
  <script>
  import { ref } from 'vue'
  
  export default {
    setup() {
      const startups = ref([
        {
          id: 1,
          name: 'Tech Innovators',
          description: 'Revolutionäre Technologielösungen',
          image: 'https://picsum.photos/seed/startup1/600/400',
          tags: ['Tech', 'AI', 'SaaS']
        },
        {
          id: 2,
          name: 'Green Solutions',
          description: 'Nachhaltige Umwelttechnologien',
          image: 'https://picsum.photos/seed/startup2/600/400',
          tags: ['Eco', 'Sustainability']
        }
      ])
      
      const addStartup = () => {
        // Hier würde normalerweise ein Dialog zum Erstellen geöffnet werden
        startups.value.push({
          id: startups.value.length + 1,
          name: 'Neues Startup ' + (startups.value.length + 1),
          description: 'Beschreibung des neuen Startups',
          image: 'https://picsum.photos/seed/new/600/400',
          tags: ['Neu']
        })
      }
  
      return { startups, addStartup }
    }
  }
  </script>