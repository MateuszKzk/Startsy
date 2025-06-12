<template>
  <q-layout view="hHh lpR fFf" class="bg-grey-2">
    <!-- Header wie im Dashboard -->
    <q-header elevated class="bg-dark text-white">
      <q-toolbar>
        <!-- Logo -->
        <q-btn flat dense to="/" class="q-mr-sm no-underline">
          <q-toolbar-title class="text-white text-left flex items-center">
            <q-icon name="rocket" size="md" class="q-mr-sm text-primary" />
            <span class="text-weight-bold">Startsy</span>
          </q-toolbar-title>
        </q-btn>

        <q-space />

        <!-- Navigation -->
        <q-tabs 
          v-model="currentTab" 
          shrink 
          stretch 
          inline-label
          class="text-white"
          active-color="primary"
          indicator-color="primary"
        >
          <q-route-tab exact name="home" label="Home" to="/" icon="home" />
          <q-route-tab name="startups" label="Startups" to="/startups" icon="business" />
          <q-route-tab name="chat" label="Chat" to="/chat" icon="chat" />
        </q-tabs>

        <q-space />

        <!-- User Dropdown -->
        <q-btn-dropdown flat stretch :label="userInitials" class="text-white">
          <q-list class="q-py-sm" style="min-width: 200px">
            <q-item clickable v-close-popup to="/profile" class="q-pa-sm">
              <q-item-section avatar>
                <q-icon name="account_circle" color="primary" />
              </q-item-section>
              <q-item-section>
                <q-item-label>Mein Profil</q-item-label>
              </q-item-section>
            </q-item>

            <q-item clickable v-close-popup to="/settings" class="q-pa-sm">
              <q-item-section avatar>
                <q-icon name="settings" color="primary" />
              </q-item-section>
              <q-item-section>
                <q-item-label>Einstellungen</q-item-label>
              </q-item-section>
            </q-item>

            <q-separator class="q-my-xs" />

            <q-item clickable v-close-popup @click="logout" class="q-pa-sm">
              <q-item-section avatar>
                <q-icon name="logout" color="negative" />
              </q-item-section>
              <q-item-section>
                <q-item-label class="text-negative">Abmelden</q-item-label>
              </q-item-section>
            </q-item>
          </q-list>
        </q-btn-dropdown>
      </q-toolbar>
    </q-header>

    <q-page-container>
      <q-page class="profile-page q-pa-lg">
        <!-- Profil Header -->
        <div class="profile-header q-mb-lg">
          <div class="row items-center q-gutter-lg">
            <q-avatar size="100px" class="profile-avatar shadow-3">
              <img :src="user.avatar || 'https://cdn.quasar.dev/img/avatar.png'">
              <q-badge v-if="user.role" floating color="accent">
                {{ user.role }}
              </q-badge>
            </q-avatar>
            
            <div class="col">
              <div class="text-h4 text-weight-bold">{{ user.full_name || user.username }}</div>
              <div class="text-subtitle1 q-mt-xs" :class="$q.dark.isActive ? 'text-grey-4' : 'text-grey-7'">
                @{{ user.username }}
              </div>
              
              <div class="row q-mt-md">
                <q-chip v-if="user.location" icon="location_on" :color="$q.dark.isActive ? 'grey-9' : 'grey-3'">
                  {{ user.location }}
                </q-chip>
                <q-chip v-if="user.job_title" icon="work" :color="$q.dark.isActive ? 'grey-9' : 'grey-3'" class="q-ml-sm">
                  {{ user.job_title }}
                </q-chip>
              </div>
            </div>
          </div>
          
          <!-- Stats -->
          <div class="row justify-around q-mt-xl q-mb-md">
            <div class="text-center">
              <div class="text-h4 text-weight-bold">{{ userStats.startups }}</div>
              <div class="text-subtitle2">Startups</div>
            </div>
            <div class="text-center">
              <div class="text-h4 text-weight-bold">{{ userStats.members }}</div>
              <div class="text-subtitle2">Mitglieder</div>
            </div>
            <div class="text-center">
              <div class="text-h4 text-weight-bold">{{ formatDate(user.created_at) }}</div>
              <div class="text-subtitle2">Mitglied seit</div>
            </div>
          </div>
        </div>

        <!-- Tabs -->
        <q-tabs 
          v-model="tab" 
          dense 
          align="justify" 
          class="q-mb-lg shadow-1"
          :class="$q.dark.isActive ? 'bg-grey-9' : 'bg-white'"
          active-color="primary"
          indicator-color="primary"
        >
          <q-tab name="startups" icon="rocket" label="Meine Startups" />
        </q-tabs>

        <q-tab-panels v-model="tab" animated class="transparent">
          <!-- Startups Tab -->
          <q-tab-panel name="startups">
            <div v-if="loading" class="text-center q-pa-lg">
              <q-spinner color="primary" size="3em" />
              <div class="text-grey-6 q-mt-sm">Lade Startups...</div>
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
            
            <div v-else class="row q-col-gutter-lg">
              <div 
                v-for="startup in startups" 
                :key="startup.id" 
                class="col-12 col-sm-6 col-md-4"
              >
                <q-card 
                  class="startup-card cursor-pointer"
                  :class="$q.dark.isActive ? 'bg-grey-9' : 'bg-white'"
                  @click="showStartupDetails(startup)"
                >
                  <q-img
                    :src="startup.logo || 'https://cdn.quasar.dev/img/placeholder.png'"
                    basic
                    style="height: 160px"
                  >
                    <div class="absolute-bottom text-h6 text-weight-bold">
                      {{ startup.name }}
                    </div>
                    <div class="absolute-top-right q-ma-xs">
                      <q-chip dense color="primary" text-color="white" icon="star" v-if="startup.is_featured">
                        Featured
                      </q-chip>
                    </div>
                  </q-img>
                  
                  <q-card-section>
                    <div class="text-caption q-mt-xs" :class="$q.dark.isActive ? 'text-grey-4' : 'text-grey-7'">
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

        <!-- Startup Details Dialog -->
        <q-dialog v-model="showDetailsDialog" persistent>
          <q-card :class="{'bg-grey-9': $q.dark.isActive}" style="width: 800px; max-width: 95vw;">
            <q-card-section class="row items-center q-pb-none">
              <div class="text-h5 text-weight-bold" :class="{'text-white': $q.dark.isActive}">
                {{ selectedStartup.name }}
              </div>
              <q-space />
              <q-btn icon="close" flat round dense v-close-popup :color="$q.dark.isActive ? 'white' : 'dark'" />
            </q-card-section>

            <q-separator spaced />

            <q-card-section class="q-pt-md">
              <div class="row q-col-gutter-lg">
                <!-- Left Column -->
                <div class="col-12 col-md-7">
                  <q-card flat bordered :class="{'bg-grey-8': $q.dark.isActive}">
                    <q-card-section>
                      <div class="text-subtitle1 text-weight-bold q-mb-sm" :class="{'text-white': $q.dark.isActive}">
                        Beschreibung
                      </div>
                      <p class="text-body1 q-mt-sm" :class="{'text-white': $q.dark.isActive}">
                        {{ selectedStartup.description || 'Keine Beschreibung vorhanden' }}
                      </p>
                    </q-card-section>

                    <q-card-section>
                      <div class="text-subtitle1 text-weight-bold q-mt-lg q-mb-sm" :class="{'text-white': $q.dark.isActive}">
                        Benötigte Skills
                      </div>
                      <div class="q-gutter-sm q-mb-sm">
                        <q-chip 
                          v-for="(skill, index) in selectedStartup.required_skills || []" 
                          :key="index"
                          color="primary" 
                          text-color="white"
                          icon="code"
                          class="q-mb-xs"
                        >
                          {{ skill }}
                        </q-chip>
                      </div>
                    </q-card-section>
                  </q-card>
                </div>

                <!-- Right Column -->
                <div class="col-12 col-md-5">
                  <q-card flat bordered :class="{'bg-grey-8': $q.dark.isActive}">
                    <q-list bordered class="rounded-borders">
                      <q-item :class="{'bg-grey-7': $q.dark.isActive}">
                        <q-item-section avatar>
                          <q-icon name="event" color="primary" />
                        </q-item-section>
                        <q-item-section>
                          <q-item-label :class="{'text-white': $q.dark.isActive}">Gegründet</q-item-label>
                          <q-item-label caption :class="{'text-grey-4': $q.dark.isActive}">
                            {{ formatDate(selectedStartup.created_at) }}
                          </q-item-label>
                        </q-item-section>
                      </q-item>

                      <q-separator />

                      <q-item :class="{'bg-grey-7': $q.dark.isActive}">
                        <q-item-section avatar>
                          <q-icon name="people" color="primary" />
                        </q-item-section>
                        <q-item-section>
                          <q-item-label :class="{'text-white': $q.dark.isActive}">Mitglieder</q-item-label>
                          <q-item-label caption :class="{'text-grey-4': $q.dark.isActive}">
                            {{ selectedStartup.members_count || 0 }}
                          </q-item-label>
                        </q-item-section>
                      </q-item>
                    </q-list>
                  </q-card>
                </div>
              </div>
            </q-card-section>
          </q-card>
        </q-dialog>
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
    const currentTab = ref('profile')
    const user = ref({})
    const startups = ref([])
    const loading = ref(true)
    const showDetailsDialog = ref(false)
    const selectedStartup = ref({})
    const userInitials = computed(() => {
      if (!user.value.full_name) return '?'
      const parts = user.value.full_name.split(' ')
      return parts.map(p => p[0]).join('').toUpperCase()
    })

    const loadUserData = async () => {
      try {
        loading.value = true
        const response = await api.get('/api/user/profile')
        user.value = response.data.user || {}
        startups.value = response.data.startups || []
        
        // Mock-Daten für die Startup-Details
        startups.value = startups.value.map(startup => ({
          ...startup,
          required_skills: ['Web Development', 'Design', 'Marketing'] // Beispiel-Skills
        }))
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

   const userStats = computed(() => {
  return {
    startups: startups.value?.length || 0,
    members: startups.value?.reduce(
      (sum, startup) => sum + (parseInt(startup.members_count) || 0),
      0
    ) || 0
  };
});


    const formatDate = (dateString) => {
      if (!dateString) return 'Unbekannt'
      try {
        return new Date(dateString).toLocaleDateString('de-DE')
      } catch {
        return dateString
      }
    }

    const showStartupDetails = (startup) => {
      selectedStartup.value = startup
      showDetailsDialog.value = true
    }

    const logout = async () => {
      try {
        await api.post('/logout')
        $router.push('/login')
      } catch (error) {
        console.error('Logout failed:', error)
      }
    }

    onMounted(() => {
      loadUserData()
    })

    return {
      tab,
      currentTab,
      user,
      startups,
      userStats,
      loading,
      showDetailsDialog,
      selectedStartup,
      userInitials,
      formatDate,
      showStartupDetails,
      logout
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
  max-width: 1200px;
  margin: 0 auto;
}

.profile-header {
  padding: 20px;
  border-radius: 12px;
  background: linear-gradient(135deg, #f5f7fa 0%, #e4e8eb 100%);
}

.body--dark .profile-header {
  background: linear-gradient(135deg, #1e1e1e 0%, #2a2a2a 100%);
}

.profile-avatar {
  border: 4px solid white;
  background: white;
}

.startup-card {
  border-radius: 12px;
  transition: all 0.3s ease;
  height: 100%;
  display: flex;
  flex-direction: column;
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
}

.body--dark .startup-card {
  box-shadow: 0 4px 12px rgba(0,0,0,0.3);
}

.startup-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 10px 20px rgba(0,0,0,0.2) !important;
}

.body--dark .startup-card:hover {
  box-shadow: 0 10px 20px rgba(0,0,0,0.4) !important;
}

.ellipsis-2-lines {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: normal;
}

.q-card__section {
  flex-grow: 1;
}

.q-img__content > div {
  background: linear-gradient(to top, rgba(0,0,0,0.7) 0%, rgba(0,0,0,0.3) 70%, rgba(0,0,0,0) 100%);
  padding: 16px;
}

.body--dark .q-img__content > div {
  background: linear-gradient(to top, rgba(0,0,0,0.9) 0%, rgba(0,0,0,0.5) 70%, rgba(0,0,0,0) 100%);
}
</style>