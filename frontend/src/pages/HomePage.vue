<template>
  <q-layout view="hHh lpR fFf">
    <!-- Header -->
    <q-header elevated class="bg-primary text-white">
      <q-toolbar>
        <q-toolbar-title class="text-left q-pl-md">Startsy</q-toolbar-title>
        <q-space />
        <q-tabs align="center">
          <q-tab label="Home" to="/home" />
          <q-tab label="Startups" to="/startups" />
          <q-tab label="About Us" to="/about" />
        </q-tabs>
        <q-space />
        <q-btn-dropdown flat color="white" icon="menu">
          <q-list>
            <q-item clickable @click="goToSettings">
              <q-item-section avatar><q-icon name="settings" /></q-item-section>
              <q-item-section>Settings</q-item-section>
            </q-item>
            <q-item clickable @click="goToProfile">
              <q-item-section avatar><q-icon name="person" /></q-item-section>
              <q-item-section>My Profile</q-item-section>
            </q-item>
            <q-item clickable @click="logout">
              <q-item-section avatar><q-icon name="logout" /></q-item-section>
              <q-item-section>Logout</q-item-section>
            </q-item>
          </q-list>
        </q-btn-dropdown>
      </q-toolbar>
    </q-header>

    <!-- Page Content -->
    <q-page-container>
      <q-page class="q-pa-md" style="background-image: url('/images/wp12482965.jpg'); background-size: cover; min-height: 100vh;">
        
        <!-- Startup Cards Grid -->
        <div class="q-gutter-md q-mt-md row justify-center">
          <!-- Add Startup Card -->
          <q-card class="cursor-pointer" style="width: 300px; height: 350px;" @click="showAddDialog = true">
            <q-card-section class="flex flex-center column" style="height: 100%">
              <q-icon name="add" size="xl" />
              <div class="text-h6 q-mt-md">Add New Startup</div>
            </q-card-section>
          </q-card>

          <!-- Startup Cards -->
          <q-card v-for="startup in startups" :key="startup.id" class="text-dark"
                  :style="`width: 300px; height: 350px; background-color: ${startup.color || '#ffffff'}; display: flex; flex-direction: column; justify-content: space-between`" 
                  @click="openStartupDetails(startup)">
            <q-card-section class="q-pa-none">
              <div class="text-h6 q-mt-md">{{ startup.name }}</div>
              <div class="text-subtitle2 q-mt-sm ellipsis-3-lines">{{ startup.description }}</div>
            </q-card-section>

            <q-card-section class="q-pa-none">
              <div class="q-mt-auto q-pa-md">
                <div class="row items-center q-gutter-sm">
                  <q-icon name="schedule" />
                  <span>{{ formatDate(startup.created_at) }}</span>
                </div>
                <div class="row items-center q-gutter-sm q-mt-sm">
                  <q-icon name="people" />
                  <span>{{ startup.members_count || 0 }} members</span>
                </div>
              </div>
            </q-card-section>
          </q-card>
        </div>

        <!-- Add Startup Dialog -->
        <q-dialog v-model="showAddDialog">
          <q-card style="min-width: 400px;">
            <q-card-section>
              <div class="text-h6">Add New Startup</div>
            </q-card-section>

            <q-card-section class="q-gutter-md">
              <q-input v-model="form.name" label="Startup Name" outlined />
              <q-input v-model="form.description" label="Description" type="textarea" outlined />
              <q-select 
                v-model="form.required_skills"
                label="Required Skills"
                :options="skillsOptions"
                multiple
                outlined
                emit-value
                map-options
              />
              <q-input v-model="form.contact_info" label="Contact Info" outlined />
              <q-select 
                v-model="form.color" 
                label="Card Color" 
                :options="colorOptions" 
                outlined 
                emit-value
                map-options
              />
            </q-card-section>

            <q-card-actions align="right">
              <q-btn flat label="Cancel" v-close-popup />
              <q-btn color="primary" label="Add" @click="submitStartup" />
            </q-card-actions>
          </q-card>
        </q-dialog>

        <!-- Startup Details Dialog -->
        <q-dialog v-model="showDetailsDialog" persistent>
          <q-card style="width: 700px; max-width: 90vw;">
            <q-card-section class="row items-center q-pb-none">
              <div class="text-h5">{{ selectedStartup.name }}</div>
              <q-space />
              <q-btn icon="close" flat round dense v-close-popup />
              <q-btn v-if="isCurrentUserFounder" 
       icon="delete" 
       color="negative" 
       flat round 
       @click="confirmDeleteStartup" />
            </q-card-section>

            <q-separator />

            <q-card-section class="q-pt-none">
              <div class="row q-col-gutter-md">
                <div class="col-7">
                  <div class="text-subtitle1 q-mb-sm">Description</div>
                  <p class="text-body1 description-scroll">{{ selectedStartup.description }}</p>


                  <div class="text-subtitle1 q-mt-md q-mb-sm">Required Skills</div>
                  <div class="q-gutter-sm">
                    <q-chip v-for="skill in selectedStartupSkills" 
                            :key="skill.id"
                            color="primary" 
                            text-color="white"
                            icon="code">
                      {{ skill.name }}
                    </q-chip>
                  </div>
                </div>

                <div class="col-5">
                  <q-list bordered>
                    <q-item>
                      <q-item-section avatar>
                        <q-icon name="event" />
                      </q-item-section>
                      <q-item-section>
                        <q-item-label>Founded</q-item-label>
                        <q-item-label caption>{{ formatDate(selectedStartup.created_at) }}</q-item-label>
                      </q-item-section>
                    </q-item>

                    <q-separator />

                    <q-item>
                      <q-item-section avatar>
                        <q-icon name="people" />
                      </q-item-section>
                      <q-item-section>
                        <q-item-label>Members</q-item-label>
                        <q-item-label caption>{{ selectedStartup.members_count || 0 }}</q-item-label>
                      </q-item-section>
                    </q-item>

                    <q-separator />

                    <q-item>
                      <q-item-section avatar>
                        <q-icon name="email" />
                      </q-item-section>
                      <q-item-section>
                        <q-item-label>Contact</q-item-label>
                        <q-item-label caption>{{ selectedStartup.contact_info }}</q-item-label>
                      </q-item-section>
                    </q-item>
                  </q-list>

                  <div class="q-mt-md">
                    <q-btn color="primary" label="Join" @click="joinStartup" class="full-width" />
                    <q-btn color="secondary" label="Contact" @click="contactFounder" class="full-width q-mt-sm" />
                  </div>
                </div>
              </div>
            </q-card-section>
          </q-card>
        </q-dialog>
      </q-page>
    </q-page-container>

    <!-- Footer -->
    <q-footer class="bg-grey-9 text-white text-center q-pa-md">
      © 2024 Startsy - All Rights Reserved
    </q-footer>
  </q-layout>
</template>

<script>
import { ref, onMounted, computed } from 'vue';
import axios from 'axios';
import { useRouter } from 'vue-router';
import { useQuasar } from 'quasar';

export default {
  setup() {
    const $q = useQuasar();
    const router = useRouter();
    
    // State
    const showAddDialog = ref(false);
    const showDetailsDialog = ref(false);
    const selectedStartup = ref({});
    const startups = ref([]);
    const currentUser = ref(null);

onMounted(async () => {
  await loadUser();
  fetchStartups();
});

const loadUser = async () => {
  try {
    const response = await axios.get('/me');
    currentUser.value = response.data;
    localStorage.setItem('user', JSON.stringify(response.data));
  } catch (error) {
    console.log(error);
    logout();
  }
};

// Axios Request Interceptor hinzufügen
axios.interceptors.request.use(config => {
  const token = localStorage.getItem('auth_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});
  // ID aus localStorage holen

  
    
    // Form
    const form = ref({
      name: '',
      description: '',
      required_skills: [],
      contact_info: '',
      color: '#ffffff'
    });

    // Options
    const skillsOptions = ref([]);
    const colorOptions = [
      { label: 'White', value: '#ffffff' },
      { label: 'Light Blue', value: '#bbdefb' },
      { label: 'Light Green', value: '#c8e6c9' },
      { label: 'Light Yellow', value: '#fff9c4' },
      { label: 'Light Red', value: '#ffcdd2' },
      { label: 'Light Purple', value: '#e1bee7' }
    ];

    // Computed
    const selectedStartupSkills = computed(() => {
      const skills = Array.isArray(selectedStartup.value.required_skills)
        ? selectedStartup.value.required_skills
        : Array.from(selectedStartup.value.required_skills || []);

      const cleanedSkills = skills
        .map(skillId => {
          return skillId.toString().trim().replace(/[{}",\s]/g, '');
        })
        .filter(skillId => skillId && skillId !== '0');

      if (!cleanedSkills.length || !skillsOptions.value.length) return [];

      return cleanedSkills.map(skillId => {
        const foundSkill = skillsOptions.value.find(skill => String(skill.value) === skillId);
        return foundSkill
          ? { id: skillId, name: foundSkill.label }
          : { id: skillId, name: `Unknown Skill (${skillId})` };
      });
    });

const isCurrentUserFounder = computed(() => {
  return selectedStartup.value.founder_id && currentUser.value.id
    ? Number(selectedStartup.value.founder_id) === Number(currentUser.value.id)
    : false;
});
    // Axios Config
    axios.defaults.baseURL = 'http://localhost:5000/';
    axios.defaults.headers.common['Content-Type'] = 'application/json';
    axios.defaults.headers.common['Accept'] = 'application/json';

    // Axios Response Interceptor
    axios.interceptors.response.use(response => response, error => {
      if (error.response.status === 401) {
        localStorage.removeItem('auth_token');
        localStorage.removeItem('user');
        router.push('/login');
      }
      return Promise.reject(error);
    });

    // Axios Request Interceptor
    axios.interceptors.request.use(config => {
      const token = localStorage.getItem('auth_token');
      if (token) config.headers.Authorization = `Bearer ${token}`;
      return config;
    });

    // Lifecycle Hooks
    onMounted(() => {
      fetchSkills();
      fetchStartups();
    });

    // Methods
    const fetchSkills = async () => {
      try {
        const res = await axios.get('http://localhost:5000/api/skills');
        skillsOptions.value = res.data.map(skill => ({ label: skill.name, value: skill.id }));
      } catch (err) {
        console.error('Fetch skills error:', err);
      }
    };

    const fetchStartups = async () => {
      try {
        const res = await axios.get('http://localhost:5000/startups');
        startups.value = res.data;
      } catch (err) {
        console.error('Fetch startups error:', err);
      }
    };

    const submitStartup = async () => {
      try {
        await axios.post('http://localhost:5000/startups', form.value);

        $q.notify({
          type: 'positive',
          message: 'Startup created successfully!',
          position: 'top'
        });

        showAddDialog.value = false;
        form.value = { name: '', description: '', required_skills: [], contact_info: '', color: '#ffffff' };
        fetchStartups();
      } catch (err) {
        console.error('Submit error:', err);
        $q.notify({
          type: 'negative',
          message: err.response?.data?.message || 'Failed to create startup',
          position: 'top'
        });
      }
    };

    const openStartupDetails = (startup) => {
  console.log('Startup Founder ID:', startup.founder_id, typeof startup.founder_id);
  console.log('Current User ID:', currentUser.value.id, typeof currentUser.value.id);
  selectedStartup.value = startup;
  showDetailsDialog.value = true;
};

    const confirmDeleteStartup = () => {
      $q.dialog({
        title: 'Confirm Deletion',
        message: 'Are you sure you want to delete this startup?',
        cancel: true,
        persistent: true
      }).onOk(() => {
        deleteStartup();
      });
    };

    const deleteStartup = async () => {
  try {
    const response = await axios.delete(`/startups/${selectedStartup.value.id}`);
    
    $q.notify({
      type: 'positive',
      message: response.data.message || 'Startup erfolgreich gelöscht',
      position: 'top'
    });

    showDetailsDialog.value = false;
    await fetchStartups(); // Liste aktualisieren
  } catch (err) {
    console.error('Fehler beim Löschen:', {
      status: err.response?.status,
      message: err.response?.data?.message || err.message
    });
    
    $q.notify({
      type: 'negative',
      message: err.response?.data?.message || 
             `Löschen fehlgeschlagen (${err.response?.status || 'Keine Antwort'})`,
      position: 'top',
      timeout: 5000
    });
  }
};

    const formatDate = (dateString) => {
      const options = { year: 'numeric', month: 'long', day: 'numeric' };
      return new Date(dateString).toLocaleDateString(undefined, options);
    };

    const joinStartup = () => {
      console.log('Joining startup:', selectedStartup.value.name);
    };

    const contactFounder = () => {
      console.log('Contacting founder of:', selectedStartup.value.name);
    };

    const goToSettings = () => {
      router.push('/settings');
    };

    const goToProfile = () => {
      router.push(`/profile/${currentUser.value.id}`);
    };

    const logout = () => {
      localStorage.removeItem('auth_token');
      localStorage.removeItem('user');
      router.push('/login');
    };

    return {
      showAddDialog,
      showDetailsDialog,
      selectedStartup,
      startups,
      currentUser,
      form,
      skillsOptions,
      colorOptions,
      selectedStartupSkills,
      submitStartup,
      openStartupDetails,
      confirmDeleteStartup,
      deleteStartup,
      formatDate,
      joinStartup,
      contactFounder,
      goToSettings,
      goToProfile,
      logout,
      isCurrentUserFounder
    };
  }
};
</script>

<style scoped>
.ellipsis-3-lines {
  display: -webkit-box;
  -webkit-line-clamp: 3;
  line-clamp:3;
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-overflow: ellipsis;
  min-height: 4.5em;
}

.q-card__section--vert {
  padding: 16px;
}

.text-dark:hover{

  filter: brightness(0.9);
  transition: 0.3s ease-in-out;
  cursor: pointer;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
  border-radius: 8px;
  transform: scale(1.02);

}

.text-dark{
  transition: 0.275s ease-in-out;
  cursor: pointer;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
  border-radius: 8px;
  transform: scale(1);
  filter: brightness(1);
}

.description-scroll {
  max-height: 120px; /* Oder was für deine UI passt */
  overflow-y: auto;
  padding-right: 4px; /* Platz für Scrollbar */
}

</style>
