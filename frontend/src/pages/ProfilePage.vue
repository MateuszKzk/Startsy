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
            <div class="col">
              <div class="text-h5 text-weight-bold">{{ user.full_name || user.username }}</div>
              <div class="text-caption q-mt-xs" :class="$q.dark.isActive ? 'text-grey-4' : 'text-grey-7'">
                @{{ user.username }}
              </div>
            </div>
          </div>

          <!-- Stats -->
          <div class="row justify-around q-mt-lg q-mb-sm">
            <div class="text-center">
              <div class="text-h5 text-weight-bold">{{ userStats.startups }}</div>
              <div class="text-caption">Startups</div>
            </div>
            <div class="text-center">
              <div class="text-h5 text-weight-bold">{{ userStats.memberships }}</div>
              <div class="text-caption">Mitgliedschaften</div>
            </div>
            <div class="text-center">
              <div class="text-h5 text-weight-bold">{{ userStats.members }}</div>
              <div class="text-caption">Mitglieder</div>
            </div>
          </div>
        </div>

        <!-- Tabs -->
        <q-tabs 
          v-model="tab" 
          dense 
          align="justify" 
          class="q-mt-md shadow-1"
          :class="$q.dark.isActive ? 'bg-dark' : 'bg-white'"
          active-color="primary"
          indicator-color="primary"
        >
          <q-tab name="startups" icon="rocket" label="Meine Startups" />
          <q-tab name="memberships" icon="groups" label="Mitgliedschaften" />
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
            
            <div v-else class="row q-col-gutter-md">
              <div 
                v-for="startup in startups" 
                :key="startup.id" 
                class="col-12 col-sm-6"
              >
                <q-card 
                  class="startup-card"
                  :class="$q.dark.isActive ? 'bg-grey-9' : 'bg-white'"
                >
                  <q-img
                    :src="startup.logo || 'https://cdn.quasar.dev/img/placeholder.png'"
                    basic
                    style="height: 140px"
                  >
                    <div class="absolute-bottom text-subtitle1 text-weight-bold">
                      {{ startup.name }}
                    </div>
                    <div class="absolute-top-right q-ma-xs">
                      <q-chip dense color="primary" text-color="white" icon="star" v-if="startup.is_featured">
                        Featured
                      </q-chip>
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
                  
                  <q-card-actions align="right">
                    <q-btn 
                      flat 
                      color="primary" 
                      label="Details" 
                      @click="openStartup(startup.id)"
                    />
                  </q-card-actions>
                </q-card>
              </div>
            </div>
          </q-tab-panel>
          
          <!-- Mitgliedschaften Tab -->
          <q-tab-panel name="memberships">
            <div v-if="loading" class="text-center q-pa-lg">
              <q-spinner color="primary" size="3em" />
              <div class="text-grey-6 q-mt-sm">Lade Daten...</div>
            </div>
            
            <div v-else-if="memberships.length === 0" class="text-center q-pa-lg">
              <q-icon name="group_add" size="xl" color="grey-4" />
              <div class="text-grey-6 q-mt-sm">Keine Mitgliedschaften vorhanden</div>
              <q-btn 
                color="primary" 
                label="Startups entdecken" 
                unelevated 
                class="q-mt-md"
                @click="$router.push('/startups')"
              />
            </div>
            
            <div v-else class="row q-col-gutter-md">
              <div 
                v-for="membership in memberships" 
                :key="membership.id" 
                class="col-12 col-sm-6"
              >
                <q-card 
                  class="startup-card"
                  :class="$q.dark.isActive ? 'bg-grey-9' : 'bg-white'"
                >
                  <q-img
                    :src="membership.logo || 'https://cdn.quasar.dev/img/placeholder.png'"
                    basic
                    style="height: 140px"
                  >
                    <div class="absolute-bottom text-subtitle1 text-weight-bold">
                      {{ membership.name }}
                    </div>
                    <div class="absolute-top-right q-ma-xs">
                      <q-chip dense color="accent" text-color="white" icon="person">
                        Mitglied
                      </q-chip>
                    </div>
                  </q-img>
                  
                  <q-card-section>
                    <div class="text-caption text-grey-6 q-mt-xs">
                      <q-icon name="people" size="16px" />
                      {{ membership.members_count }} Mitglieder • 
                      <q-icon name="calendar_today" size="16px" class="q-ml-xs" />
                      {{ formatDate(membership.joined_at) }}
                    </div>
                    <div class="text-caption ellipsis-2-lines q-mt-sm">
                      {{ membership.description || 'Keine Beschreibung vorhanden' }}
                    </div>
                  </q-card-section>
                  
                  <q-card-actions align="right">
                    <q-btn 
                      flat 
                      color="primary" 
                      label="Details" 
                      @click="openStartup(membership.id)"
                    />
                  </q-card-actions>
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
    const memberships = ref([])
    const loading = ref(true)

    const loadUserData = async () => {
      try {
        loading.value = true
        
        // Benutzerdaten und Startups laden
        const [profileRes, membershipsRes] = await Promise.all([
          api.get('/api/user/profile'),
          api.get('/startups') // Alle Startups laden und dann filtern
        ])
        
        user.value = profileRes.data.user || {}
        startups.value = profileRes.data.startups || []
        
        // Mitgliedschaften aus allen Startups filtern
        const allStartups = membershipsRes.data || []
        const membershipsResponse = await api.get('/api/me')
        const userId = membershipsResponse.data.user.id
        
        // Temporär: Wir nehmen an, dass der User Mitglied in allen Startups ist, wo er nicht Gründer ist
        memberships.value = allStartups.filter(startup => {
          return startup.founder_id !== userId && 
                 startups.value.findIndex(s => s.id === startup.id) === -1
        }).map(startup => ({
          ...startup,
          joined_at: startup.created_at // Da wir kein richtiges Beitrittsdatum haben
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
        startups: startups.value.length,
        memberships: memberships.value.length,
        members: startups.value.reduce((sum, s) => sum + (parseInt(s.members_count) || 0), 0)
      }
    })

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
      memberships,
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
  max-width: 1000px;
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

.startup-card {
  border-radius: 12px;
  transition: all 0.3s ease;
  height: 100%;
  display: flex;
  flex-direction: column;
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
  white-space: normal;
}

.q-card__actions {
  margin-top: auto;
}
</style>