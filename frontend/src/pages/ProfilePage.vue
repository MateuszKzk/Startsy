<template>
  <q-layout view="hHh Lpr lFf" class="profile-layout">
    <q-header elevated class="bg-primary text-white">
      <q-toolbar>
        <q-btn flat round dense icon="arrow_back" @click="$router.go(-1)" />
        <q-toolbar-title class="text-weight-bold">Profil</q-toolbar-title>
        <q-btn flat round dense icon="settings" @click="navigateToSettings" />
      </q-toolbar>
    </q-header>

    <q-page-container>
      <q-page class="profile-page q-pa-md">
        <!-- Profilkarte -->
        <div class="profile-card q-pa-md" :class="$q.dark.isActive ? 'bg-dark' : 'bg-white'">
          <div class="row items-center q-gutter-md">
            <q-avatar size="80px" class="profile-avatar shadow-3">
              <img :src="user.avatar || 'https://cdn.quasar.dev/img/avatar.png'">
              <q-badge v-if="user.role" floating color="accent">
                {{ user.role }}
              </q-badge>
            </q-avatar>
            <div>
              <div class="text-h5 text-weight-bold">{{ user.full_name || user.username }}</div>
              <div class="text-subtitle2 q-mt-xs" :class="$q.dark.isActive ? 'text-grey-4' : 'text-grey-7'">
              </div>
            </div>
          </div>

          <!-- Stats -->
          <div class="row justify-around q-mt-lg">
            <div class="text-center">
              <div class="row items-center justify-center q-gutter-xs">
                <q-icon name="rocket" size="20px" color="primary" />
                <div class="text-h5 text-weight-bold">{{ userStats.startups }}</div>
              </div>
              <div class="text-caption">Startups</div>
            </div>
            <div class="text-center">
              <div class="row items-center justify-center q-gutter-xs">
                <q-icon name="people" size="20px" color="primary" />
                <div class="text-h5 text-weight-bold">{{ userStats.members }}</div>
              </div>
              <div class="text-caption">Mitglieder</div>
            </div>
          </div>
        </div>

        <!-- Tabs -->
        <q-tabs 
          v-model="tab" 
          dense 
          align="justify" 
          class="q-mt-md"
          :class="$q.dark.isActive ? 'bg-dark' : 'bg-white'"
          active-color="primary"
          indicator-color="primary"
        >
          <q-tab name="startups" icon="rocket" label="Meine Startups" />
        </q-tabs>

        <q-tab-panels v-model="tab" animated class="transparent q-mt-sm">
          <!-- Startups Tab -->
          <q-tab-panel name="startups">
            <div v-if="loading" class="text-center q-pa-lg">
              <q-spinner color="primary" size="3em" />
              <div class="text-grey-6 q-mt-sm">Lade Daten...</div>
            </div>
            
            <div v-else-if="startups.length === 0" class="text-center q-pa-lg">
              <q-icon name="rocket_launch" size="xl" color="grey-4" />
              <div class="text-grey-6 q-mt-sm">Noch keine Startups vorhanden</div>
              <q-btn 
                color="primary" 
                label="Startup erstellen" 
                unelevated 
                class="q-mt-md"
                @click="$router.push('/startups/create')"
              />
            </div>
            
            <!-- Horizontale Scroll-Liste für Startups -->
            <div v-else class="horizontal-scroll-container">
              <div class="horizontal-scroll-content">
                <q-card 
                  v-for="startup in startups" 
                  :key="startup.id" 
                  class="startup-card"
                  :class="$q.dark.isActive ? 'bg-grey-9' : 'bg-white'"
                  @click="openStartup(startup.id)"
                >
                  <q-img
                    :src="startup.logo || 'https://cdn.quasar.dev/img/placeholder.png'"
                    basic
                    style="height: 120px"
                  >
                    <div class="absolute-bottom text-subtitle1 text-weight-bold">
                      {{ startup.name }}
                    </div>
                  </q-img>
                  
                  <q-card-section>
                    <div class="text-caption text-grey-6 q-mt-xs">
                      <q-icon name="people" size="16px" />
                      {{ startup.members_count }} Mitglieder • 
                      <q-icon name="calendar_today" size="16px" class="q-ml-xs" />
                      {{ formatDate(startup.created_at) }}
                    </div>
                    <div class="text-caption ellipsis-2-lines q-mt-sm">
                      {{ startup.description || 'Keine Beschreibung vorhanden' }}
                    </div>
                  </q-card-section>
                </q-card>
              </div>
            </div>
          </q-tab-panel>
        </q-tab-panels>
      </q-page>
    </q-page-container>
  </q-layout>
</template>

<script>
import { defineComponent, ref, onMounted, computed } from 'vue'
import { useQuasar } from 'quasar'
import { useRouter } from 'vue-router'
import { api } from 'boot/axios'

export default defineComponent({
  name: 'ProfilePage',
  setup() {
    const $q = useQuasar()
    const $router = useRouter()
    const tab = ref('startups')
    const user = ref({})
    const startups = ref([])
    const loading = ref(true)

    // Dark Mode aus Backend laden
    const loadDarkMode = async () => {
      try {
        const response = await api.get('/api/user/settings')
        $q.dark.set(response.data.dark_mode)
      } catch (error) {
        console.error('Fehler beim Laden des Dark Modes:', error)
      }
    }

    const userStats = computed(() => {
      return {
        startups: startups.value.length,
        members: startups.value.reduce((sum, s) => sum + (parseInt(s.members_count) || 0), 0)
      }
    })

    const loadUserData = async () => {
      try {
        loading.value = true
        await loadDarkMode()
        
        // Benutzerdaten und Startups in einem Request laden
        const response = await api.get('/api/user/profile')
        user.value = response.data.user || {}
        startups.value = response.data.startups || []
        
      } catch (error) {
        console.error('Fehler beim Laden:', error)
        $q.notify({
          type: 'negative',
          message: 'Profil konnte nicht geladen werden',
          caption: error.response?.data?.message || error.message
        })
      } finally {
        loading.value = false
      }
    }

    const formatDate = (dateString) => {
      if (!dateString) return 'Unbekannt'
      try {
        return new Date(dateString).toLocaleDateString('de-DE')
      } catch {
        return dateString
      }
    }

    const navigateToSettings = () => {
      $router.push('/settings')
    }

    const openStartup = (id) => {
      $router.push(`/startups/${id}`)
    }

    onMounted(() => {
      loadUserData()
    })

    return {
      tab,
      user,
      startups,
      userStats,
      loading,
      formatDate,
      navigateToSettings,
      openStartup
    }
  }
})
</script>

<style scoped>
.profile-layout {
  background: #f5f7fa;
}

.body--dark .profile-layout {
  background: #121212;
}

.profile-page {
  max-width: 600px;
  margin: 0 auto;
}

.profile-card {
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0,0,0,0.1);
}

.profile-avatar {
  border: 3px solid white;
  background: white;
}

/* Horizontale Scroll-Liste */
.horizontal-scroll-container {
  overflow-x: auto;
  overflow-y: hidden;
  white-space: nowrap;
  padding: 8px 0;
  -webkit-overflow-scrolling: touch;
}

.horizontal-scroll-content {
  display: inline-flex;
  gap: 16px;
}

.startup-card {
  width: 280px;
  display: inline-flex;
  flex-direction: column;
  border-radius: 12px;
  transition: all 0.3s ease;
  vertical-align: top;
  white-space: normal;
}

.startup-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 10px 20px rgba(0,0,0,0.15) !important;
}

.ellipsis-2-lines {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-overflow: ellipsis;
}
</style>