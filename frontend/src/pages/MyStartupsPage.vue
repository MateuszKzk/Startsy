<template>
  <!-- In Ihrem Quasar-Plugin-Import -->
<link href="https://cdn.jsdelivr.net/npm/@mdi/font@6.9.96/css/materialdesignicons.min.css" rel="stylesheet">
  <q-layout view="hHh lpR fFf">
    <!-- ==================== -->
    <!-- HEADER SECTION -->
    <!-- ==================== -->
    <q-header elevated class="bg-dark">
  <q-toolbar>
    <!-- Logo -->
    <q-btn flat dense to="/" class="q-mr-sm">
      <q-toolbar-title class="text-white text-left">
        <q-icon name="rocket" size="md" class="q-mr-sm" />
        Startsy
      </q-toolbar-title>
    </q-btn>

    <q-space />

    <!-- Navigation for logged in users -->
    <template v-if="currentUser">
      <q-tabs v-model="currentTab" shrink stretch inline-label>
        <q-route-tab exact name="home" label="Home" to="/" icon="home" />
        <q-route-tab name="startups" label="Startups" to="/startups" icon="business" />
        <q-route-tab name="about" label="About" to="/about" icon="info" />
      </q-tabs>

      <q-space />

      <!-- Such- und Filterfunktionen -->
      <div class="row items-center q-gutter-sm q-pr-md">
        <!-- Suchfeld -->
        <q-input
  v-model="searchQuery"
  outlined
  dense
  placeholder="Search startups..."
  class="search-field"
  clearable
  dark
  borderless
  input-class="text-white"
  @keyup.enter="performSearch"
  @clear="performSearch"
>
  <template v-slot:prepend>
    <q-icon name="search" color="white" @click="performSearch" />
  </template>
</q-input>

<!-- Kategorie-Filter anpassen -->
<q-select
  v-model="selectedCategory"
  :options="categories"
  outlined
  dense
  label="Filter by category"
  class="category-filter"
  dark
  borderless
  clearable
  emit-value
  map-options
  style="min-width: 180px"
  @update:model-value="performSearch"
>
  <template v-slot:prepend>
    <q-icon name="filter_list" color="white" />
  </template>
  <template v-slot:append>
    <q-icon 
      v-if="selectedCategory" 
      name="close" 
      class="cursor-pointer" 
      @click.stop="selectedCategory = null" 
    />
  </template>
</q-select>
      </div>

      <q-space />

      <!-- User Dropdown -->
      <q-btn-dropdown flat stretch :label="userInitials" class="text-white">
        <q-list>
          <q-item clickable v-close-popup to="/profile">
            <q-item-section avatar>
              <q-icon name="account_circle" />
            </q-item-section>
            <q-item-section>My Profile</q-item-section>
          </q-item>

          <q-item clickable v-close-popup to="/settings">
            <q-item-section avatar>
              <q-icon name="settings" />
            </q-item-section>
            <q-item-section>Settings</q-item-section>
          </q-item>

          <q-separator />

          <q-item clickable v-close-popup @click="logout">
            <q-item-section avatar>
              <q-icon name="logout" color="negative" />
            </q-item-section>
            <q-item-section class="text-negative">Logout</q-item-section>
          </q-item>
        </q-list>
      </q-btn-dropdown>
    </template>

    <!-- Login Button for guests -->
    <q-btn v-else outline color="white" label="Login" :to="{ name: 'login' }" />
  </q-toolbar>
</q-header>

    <!-- ==================== -->
    <!-- MAIN CONTENT SECTION -->
    <!-- ==================== -->
    <q-page-container>
      <q-page class="q-pa-md">

        <!-- Startup Cards Grid -->
        <div class="q-gutter-md q-mt-md row justify-center">
          <!-- Add Startup Card -->
          <!-- Add Startup Card -->
<q-card class="my-card cursor-pointer" @click="showAddDialog = true">
  <q-card-section class="flex flex-center column" style="height: 100%;">
    <q-icon name="add" size="xl" color="grey-6" />
    <div class="text-h6 q-mt-md text-grey-7">Add New Startup</div>
  </q-card-section>
</q-card>

          <!-- Startup Cards -->
          <q-card 
  v-for="startup in filteredStartups" 
  :key="startup.id" 
  class="my-card text-dark"
  :style="`background-color: ${startup.color || '#ffffff'}`"
  @click="openStartupDetails(startup)"
>
  <q-card-section>
    <div class="text-h6 text-weight-bold">{{ startup.name }}</div>
    <div class="text-subtitle2 q-mt-sm ellipsis-3-lines">
      {{ startup.description }}
    </div>
  </q-card-section>

  <q-separator />

  <q-card-section class="q-pt-none">
    <div class="row items-center q-gutter-sm">
      <q-icon name="schedule" size="sm" />
      <span class="text-caption">{{ formatDate(startup.created_at) }}</span>
    </div>
    <div class="row items-center q-gutter-sm q-mt-sm">
      <q-icon name="people" size="sm" />
      <span class="text-caption">{{ startup.members_count || 0 }} members</span>
    </div>
  </q-card-section>

  <q-card-actions align="right">
    <q-btn 
      flat 
      color="primary" 
      label="Details" 
      @click.stop="openStartupDetails(startup)"
    />
  </q-card-actions>
</q-card>
        </div>

        <!-- ==================== -->
        <!-- ADD STARTUP DIALOG -->
        <!-- ==================== -->
        <q-dialog v-model="showAddDialog">
          <q-card style="min-width: 400px;">
            <q-card-section>
              <div class="text-h6">Add New Startup</div>
            </q-card-section>

            <q-card-section class="q-gutter-md">
              <q-input v-model="form.name" label="Startup Name" outlined />
              <q-input v-model="form.description" label="Description" type="textarea" outlined />

              <!-- Skill Selection -->
              <div class="q-mb-md">
                <div class="text-caption q-mb-sm">Required Skills</div>
                <q-input v-model="skillSearch" outlined dense placeholder="Search skills..." class="q-mb-sm" clearable>
                  <template v-slot:prepend>
                    <q-icon name="search" />
                  </template>
                </q-input>
                <div class="q-gutter-sm q-mb-sm" style="max-height: 200px; overflow-y: auto;">
                  <q-chip v-for="skill in filteredSkills" :key="skill.id" clickable
                    :color="form.required_skills.includes(skill.id) ? 'primary' : 'grey-4'"
                    :text-color="form.required_skills.includes(skill.id) ? 'white' : 'dark'"
                    @click="toggleSkill(skill.id)">
                    {{ skill.name }}
                    <q-icon v-if="form.required_skills.includes(skill.id)" name="check" class="q-ml-xs" />
                  </q-chip>
                </div>
              </div>

              <div class="q-mb-md">
  <div class="text-caption text-weight-medium q-mb-sm">Contact Information</div>
  <div class="q-gutter-y-sm">
    <div v-for="(contact, index) in form.contacts" :key="index" class="row items-center no-wrap q-gutter-sm">
      <q-select
        v-model="contact.type"
        :options="contactOptions"
        outlined
        dense
        style="width: 120px; height: 40px"
        emit-value
        map-options
        class="contact-type-select"
      />
      <q-input
        v-model="contact.value"
        outlined
        dense
        class="col contact-value-input"
        style="height: 40px"
        :rules="contact.type === 'email' ? [val => isValidEmail(val) || 'Invalid email'] : []"
      />
      <q-btn
        icon="remove"
        round
        dense
        flat
        color="negative"
        @click="removeContact(index)"
        v-if="form.contacts.length > 1"
        style="height: 40px; width: 40px"
      />
    </div>
    <q-btn
      icon="add"
      label="Add Contact"
      dense
      flat
      color="primary"
      @click="addContact"
      class="q-mt-sm"
    />
  </div>
</div>
    </q-card-section>

            <q-card-actions align="right">
              <q-btn flat label="Cancel" v-close-popup />
              <q-btn color="primary" label="Add" @click="submitStartup" />
            </q-card-actions>
          </q-card>
        </q-dialog>

        <!-- ==================== -->
        <!-- STARTUP DETAILS DIALOG -->
        <!-- ==================== -->
        <q-dialog v-model="showDetailsDialog" persistent>
  <q-card style="width: 800px; max-width: 95vw;">
    <q-card-section class="row items-center q-pb-none">
      <div class="text-h5">{{ selectedStartup.name }}</div>
      <q-space />
      <q-btn icon="close" flat round dense v-close-popup />
      <q-btn 
        v-if="isCurrentUserFounder" 
        icon="delete" 
        color="negative" 
        flat round 
        @click="confirmDeleteStartup" 
      />
    </q-card-section>

    <q-separator spaced/>

    <q-card-section class="q-pt-md">
      <div class="row q-col-gutter-lg">
        <!-- Left Column (Description & Skills) -->
        <div class="col-12 col-md-7">
          <q-card flat bordered>
            <q-card-section>
              <div class="text-subtitle1">Description</div>
              <p class="text-body1 q-mt-sm">{{ selectedStartup.description }}</p>
            </q-card-section>

            <q-card-section>
              <div class="text-subtitle1 q-mt-md q-mb-sm">Required Skills</div>
<div class="q-gutter-sm" style="max-height: 120px; overflow-y: auto;">
  <q-chip 
    v-for="skill in selectedStartupSkills" 
    :key="skill.id"
    color="primary" 
    text-color="white"
    icon="code"
    class="q-mb-xs"
  >
    {{ skill.name }}
  </q-chip>
</div>
            </q-card-section>
          </q-card>
        </div>

        <!-- Right Column (Info & Actions) -->
        <div class="col-12 col-md-5">
          <q-card flat bordered>
            <q-card-section>
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

                <template v-for="(contact, index) in parsedContacts" :key="index">
                  <q-item>
                    <q-item-section avatar>
                      <q-icon :name="getContactIcon(contact.type)" />
                    </q-item-section>
                    <q-item-section>
                      <q-item-label>{{ getContactLabel(contact.type) }}</q-item-label>
                      <q-item-label caption>
                        <a v-if="contact.type === 'email'" :href="`mailto:${contact.value}`">{{ contact.value }}</a>
                        <a v-else-if="contact.type === 'phone'" :href="`tel:${contact.value}`">{{ contact.value }}</a>
                        <span v-else>{{ contact.value }}</span>
                      </q-item-label>
                    </q-item-section>
                  </q-item>
                  <q-separator v-if="index < parsedContacts.length - 1" />
                </template>
              </q-list>
            </q-card-section>

            <q-card-actions vertical>
              <q-btn 
                color="primary" 
                label="Join Startup" 
                @click="joinStartup" 
                class="q-mb-sm"
              />
            </q-card-actions>
          </q-card>
        </div>
      </div>
    </q-card-section>
  </q-card>
</q-dialog>
      </q-page>
    </q-page-container>

    <q-dialog v-model="showSearchResults" persistent>
  <q-card style="width: 800px; max-width: 95vw;">
    <q-card-section class="row items-center q-pb-none">
      <div class="text-h5">Search Results</div>
      <q-space />
      <q-btn icon="close" flat round dense v-close-popup />
    </q-card-section>

    <q-separator spaced/>

    <q-card-section>
      <div class="row q-col-gutter-md">
        <div 
          v-for="startup in searchResults" 
          :key="startup.id" 
          class="col-12 col-sm-6 col-md-4"
        >
          <q-card 
            class="my-card text-dark cursor-pointer"
            :style="`background-color: ${startup.color || '#ffffff'}`"
            @click="openStartupDetails(startup)"
          >
            <q-card-section>
              <div class="text-h6 text-weight-bold">{{ startup.name }}</div>
              <div class="text-subtitle2 q-mt-sm ellipsis-3-lines">
                {{ startup.description }}
              </div>
            </q-card-section>

            <q-separator />

            <q-card-section class="q-pt-none">
              <div class="row items-center q-gutter-sm">
                <q-icon name="schedule" size="sm" />
                <span class="text-caption">{{ formatDate(startup.created_at) }}</span>
              </div>
              <div class="row items-center q-gutter-sm q-mt-sm">
                <q-icon name="people" size="sm" />
                <span class="text-caption">{{ startup.members_count || 0 }} members</span>
              </div>
            </q-card-section>
          </q-card>
        </div>
      </div>
    </q-card-section>
  </q-card>
</q-dialog>

    <!-- ==================== -->
    <!-- FOOTER SECTION -->
    <!-- ==================== -->
    <q-footer class="bg-grey-9 text-white text-center q-pa-md">
      © 2024 Startsy - All Rights Reserved
    </q-footer>
  </q-layout>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { useQuasar } from 'quasar'
import { useRouter } from 'vue-router'
import axios from 'axios'
import { watch } from 'vue'

export default {
  name: 'DashboardPage',

  setup() {
    const $q = useQuasar()
    const router = useRouter()

    // ==================== //
    // REACTIVE STATE
    // ==================== //
    const showAddDialog = ref(false)
    const showDetailsDialog = ref(false)
    const selectedStartup = ref({})
    const startups = ref([])
    const currentUser = ref(null)
    const darkMode = ref(false)
    const darkModeLoading = ref(false)
    const skillSearch = ref('')
    const currentTab = ref('home') // Added to fix tab warning
    const searchQuery = ref('')
    const selectedCategory = ref(null)
    const showSearchResults = ref(false)
    const searchResults = ref([])

    const categories = ref([
    { label: 'All Categories', value: null },
  { 
    
    label: 'Web Development', 
    value: 'web',
    icon: 'code',
    color: 'blue'
  },
  { 
    label: 'Backend', 
    value: 'backend',
    icon: 'storage',
    color: 'deep-purple'
  },
  { 
    label: 'Database', 
    value: 'database',
    icon: 'dns',
    color: 'teal'
  },
  { 
    label: 'DevOps', 
    value: 'devops',
    icon: 'settings_suggest',
    color: 'orange'
  },
  { 
    label: 'Mobile', 
    value: 'mobile',
    icon: 'phone_iphone',
    color: 'pink'
  },
  { 
    label: 'Data Science', 
    value: 'data-science',
    icon: 'insights',
    color: 'green'
  },
  { 
    label: 'AI/ML', 
    value: 'ai-ml',
    icon: 'psychology',
    color: 'purple'
  },
  { 
    label: 'Systems', 
    value: 'systems',
    icon: 'computer',
    color: 'grey'
  },
  { 
    label: 'Security', 
    value: 'security',
    icon: 'security',
    color: 'red'
  },
  { 
    label: 'Game Dev', 
    value: 'game-dev',
    icon: 'sports_esports',
    color: 'amber'
  },
  { 
    label: 'Embedded Systems', 
    value: 'embedded',
    icon: 'memory',
    color: 'blue-grey'
  },
  { 
    label: 'Emerging Tech', 
    value: 'emerging-tech',
    icon: 'experiment',
    color: 'cyan'
  },
  { 
    label: 'Version Control', 
    value: 'version-control',
    icon: 'fork',
    color: 'brown'
  }
])
   
    // ==================== //
    // API CONFIGURATION
    // ==================== //
    const api = axios.create({
      baseURL: 'http://localhost:5000',
      withCredentials: true
    })

    // ==================== //
    // FORM STATE
    // ==================== //
     const form = ref({
              name: '',
              description: '',
              required_skills: [],
              contacts: [{ type: 'email', value: '' }], // Start with one email field
              color: '#ffffff'
            })

    // ==================== //
    // UI OPTIONS
    // ==================== //
    const skillsOptions = ref([])
    const colorOptions = [
      { label: 'White', value: '#ffffff' },
      { label: 'Light Blue', value: '#bbdefb' },
      { label: 'Light Green', value: '#c8e6c9' },
      { label: 'Light Yellow', value: '#fff9c4' },
      { label: 'Light Red', value: '#ffcdd2' },
      { label: 'Light Purple', value: '#e1bee7' } 
      ]
const contactOptions = [
  { label: 'Email', value: 'email' },
  { label: 'Phone', value: 'phone' },
  { label: 'LinkedIn', value: 'linkedin' },
  { label: 'Twitter', value: 'twitter' },
  { label: 'Discord', value: 'discord' },
  { label: 'Other', value: 'other' }
  ]
    // ==================== //
    // COMPUTED PROPERTIES
    // ==================== //

    const filteredStartups = computed(() => {
  if (!startups.value) return []
  
  let result = [...startups.value]
  
  // Kategorie-Filter
  if (selectedCategory.value) {
    result = result.filter(startup => 
      startup.category === selectedCategory.value
    )
  }
  
  // Such-Filter
  if (searchQuery.value?.trim()) {
    const query = searchQuery.value.trim().toLowerCase()
    result = result.filter(startup => {
      const nameMatch = startup.name?.toLowerCase().includes(query) || false
      const descMatch = startup.description?.toLowerCase().includes(query) || false
      return nameMatch || descMatch
    })
  }
  
  return result
})


    const filteredSkills = computed(() => {
      if (!skillSearch.value) return skillsOptions.value
      const search = skillSearch.value.toLowerCase()
      return skillsOptions.value.filter(skill => 
        skill.name.toLowerCase().includes(search)
      )
    })

    const selectedStartupSkills = computed(() => {
      if (!selectedStartup.value.required_skills || !skillsOptions.value.length) {
        return []
      }
      
      let skillIds = selectedStartup.value.required_skills
      if (typeof skillIds === 'string') {
        try {
          skillIds = JSON.parse(skillIds)
        } catch {
          skillIds = skillIds.split(',').map(id => id.trim())
        }
      }
      
      return skillIds
        .map(id => skillsOptions.value.find(skill => skill.id == id))
        .filter(skill => skill)
    })

    const isCurrentUserFounder = computed(() => {
      return selectedStartup.value.founder_id && currentUser.value?.id
        ? Number(selectedStartup.value.founder_id) === Number(currentUser.value.id)
        : false
    })

    const userInitials = computed(() => {
      if (!currentUser.value) return ''
      const { first_name, last_name } = currentUser.value
      return `${first_name?.[0] || ''}${last_name?.[0] || ''}`.toUpperCase()
    })

    const parsedContacts = computed(() => {
  if (!selectedStartup.value.contacts) return []
  try {
    return typeof selectedStartup.value.contacts === 'string' 
      ? JSON.parse(selectedStartup.value.contacts)
      : selectedStartup.value.contacts
  } catch {
    return []
  }
})

    // ==================== //
    // METHODS - USER RELATED
    // ==================== //

    

    const loadUser = async () => {
      try {
        const response = await api.get('/me')
        currentUser.value = response.data
      } catch (error) {
        console.error('User load error:', error)
        logout()
      }
    }

    const logout = async () => {
      try {
        await api.post('/logout')
      } catch (error) {
        console.log('Logout API error:', error)
      } finally {
        window.location.href = '/login'
      }
    }

    // ==================== //
    // METHODS - SETTINGS
    // ==================== //

    const addContact = () => {
  form.value.contacts.push({ type: 'email', value: '' })
}

const removeContact = (index) => {
  form.value.contacts.splice(index, 1)
}

const isValidEmail = (email) => {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)
}

    const loadSettings = async () => {
      try {
        darkModeLoading.value = true
        const response = await api.get('/api/user/settings')
        darkMode.value = response.data.dark_mode
        $q.dark.set(darkMode.value)
      } catch (error) {
        console.error('Settings load error:', error)
      } finally {
        darkModeLoading.value = false
      }
    }

    const saveSettings = async () => {
      try {
        darkModeLoading.value = true
        await api.post('/api/user/settings', { dark_mode: darkMode.value })
        $q.dark.set(darkMode.value)
      } catch (error) {
        console.error('Settings save error:', error)
      } finally {
        darkModeLoading.value = false
      }
    }

    // ==================== //
    // METHODS - SKILLS
    // ==================== //

    const fetchSkills = async () => {
      try {
        const res = await api.get('/api/skills')
        skillsOptions.value = res.data.map(skill => ({ 
          id: skill.id,
          name: skill.name,
          label: skill.name, 
          value: skill.id
        }))
      } catch (err) {
        console.error('Fetch skills error:', err)
        $q.notify({
          type: 'negative',
          message: 'Failed to load skills',
          position: 'top'
        })
      }
    }

    const toggleSkill = (skillId) => {
      const index = form.value.required_skills.indexOf(skillId)
      if (index === -1) {
        form.value.required_skills.push(skillId)
      } else {
        form.value.required_skills.splice(index, 1)
      }
    }

    // ==================== //
    // METHODS - STARTUPS
    // ==================== //
    const fetchStartups = async () => {
  try {
    const res = await api.get('/startups')
    startups.value = res.data.map(startup => ({
      ...startup,
      // Setzen Sie eine Standardkategorie, falls nicht vorhanden
      category: startup.category || 'web'
    }))
  } catch (err) {
    console.error('Fetch startups error:', err)
    $q.notify({
      type: 'negative',
      message: 'Failed to load startups',
      position: 'top'
    })
  }
}

    const submitStartup = async () => {
  try {
    // Validate at least one contact is provided
    if (form.value.contacts.some(c => !c.value.trim())) {
      $q.notify({
        type: 'negative',
        message: 'Please fill in all contact fields',
        position: 'top'
      })
      return
    }
    
    const payload = {
      ...form.value,
      required_skills: form.value.required_skills.join(','),
      contacts: JSON.stringify(form.value.contacts)
    }
    
    await api.post('/startups', payload)

    $q.notify({
      type: 'positive',
      message: 'Startup created successfully!',
      position: 'top'
    })

    showAddDialog.value = false
    form.value = { 
      name: '', 
      description: '', 
      required_skills: [], 
      contacts: [{ type: 'email', value: '' }],
      color: '#ffffff' 
    }
    await fetchStartups()
  } catch (err) {
    console.error('Submit error:', err)
    $q.notify({
      type: 'negative',
      message: err.response?.data?.message || 'Failed to create startup',
      position: 'top'
    })
  }
}

    const openStartupDetails = (startup) => {
      selectedStartup.value = startup
      showDetailsDialog.value = true
    }

    const confirmDeleteStartup = () => {
      $q.dialog({
        title: 'Confirm Deletion',
        message: 'Are you sure you want to delete this startup?',
        cancel: true,
        persistent: true
      }).onOk(() => deleteStartup())
    }

    const deleteStartup = async () => {
      try {
        await api.delete(`/startups/${selectedStartup.value.id}`)
        
        $q.notify({
          type: 'positive',
          message: 'Startup deleted successfully',
          position: 'top'
        })

        showDetailsDialog.value = false
        await fetchStartups()
      } catch (err) {
        console.error('Delete error:', err)
        $q.notify({
          type: 'negative',
          message: err.response?.data?.message || 'Failed to delete startup',
          position: 'top'
        })
      }
    }

    const joinStartup = async () => {
      try {
        await api.post(`/startups/${selectedStartup.value.id}/join`)
        $q.notify({
          type: 'positive',
          message: 'Successfully joined startup',
          position: 'top'
        })
        await fetchStartups()
      } catch (err) {
        console.error('Join error:', err)
        $q.notify({
          type: 'negative',
          message: err.response?.data?.message || 'Failed to join startup',
          position: 'top'
        })
      }
    }

    const clearFilters = () => {
  searchQuery.value = ''
  selectedCategory.value = null
  performSearch()
}
const performSearch = () => {
  // Deaktivieren Sie das Popup und nutzen Sie nur die Hauptansicht
  showSearchResults.value = false
  
  // Die Filterung wird automatisch durch filteredStartups übernommen
  // Zusätzliche Benachrichtigung für Nutzerfeedback
  if (searchQuery.value?.trim()) {
    $q.notify({
      message: `Found ${filteredStartups.value.length} results`,
      color: 'positive',
      position: 'top'
    })
  }
}


     // ==================== //
    // CONTACT METHODS
    // ==================== //

  const getContactIcon = (type) => {
  const icons = {
    email: 'email',
    phone: 'phone',
    linkedin: 'mdi-linkedin',
    twitter: 'mdi-twitter',
    discord: 'mdi-discord',
    other: 'contact_page'
  }
  return icons[type] || 'contact_page'
}

const getContactLabel = (type) => {
  const labels = {
    email: 'Email',
    phone: 'Phone',
    linkedin: 'LinkedIn',
    twitter: 'Twitter',
    discord: 'Discord',
    other: 'Contact'
  }
  return labels[type] || 'Contact'
}

    // ==================== //
    // UTILITY METHODS
    // ==================== //
    const formatDate = (dateString) => {
      const options = { year: 'numeric', month: 'long', day: 'numeric' }
      return new Date(dateString).toLocaleDateString(undefined, options)
    }

    const contactFounder = () => {
      console.log('Contacting founder of:', selectedStartup.value.name)
    }

    const goToSettings = () => {
      router.push('/settings')
    }

    const goToProfile = () => {
      if (currentUser.value?.id) {
        router.push(`/profile/${currentUser.value.id}`)
      }
    }

    // ==================== //
    // LIFECYCLE HOOKS
    // ==================== //
    onMounted(async () => {
      await loadUser()
      await fetchSkills()
      await fetchStartups()
      await loadSettings()
    })

    watch(darkMode, saveSettings)

    watch([searchQuery, selectedCategory], () => {
  performSearch()
})


    // ==================== //
    // EXPOSED TO TEMPLATE
    // ==================== //
    return {
      // State
      showAddDialog,
      showDetailsDialog,
      selectedStartup,
      startups,
      currentUser,
      form,
      skillSearch,
      currentTab, // Added to fix tab warning
      
      // Options
      skillsOptions,
      colorOptions,
      
      // Computed
      filteredSkills,
      selectedStartupSkills,
      isCurrentUserFounder,
      userInitials,
      
      // Methods
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
      toggleSkill,
      contactOptions,
      addContact,
      removeContact,
      isValidEmail,
      getContactIcon,
      getContactLabel,
      parsedContacts,
      categories, 
      filteredStartups,
      clearFilters,
      showSearchResults,
      searchResults,
      performSearch,
      searchQuery,
      selectedCategory
    }
  }
}
</script>

<style scoped>
/* ==================== */
/* CARD STYLES */
/* ==================== */
.my-card {
  width: 300px;
  min-height: 350px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  border: 1px solid rgba(0, 0, 0, 0.2);
  transition: all 0.3s ease;
}

.body--dark .my-card {
  border: 1px solid rgba(255, 255, 255, 0.12);
}

.my-card:hover {
  border-color: var(--q-primary);
  transform: translateY(-5px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
}

.contact-type-select .q-field__control {
  height: 40px;
}

.contact-value-input .q-field__control {
  height: 40px;
}

/* Konsistente Ausrichtung der Elemente */
.row.items-center.no-wrap {
  align-items: center;
}

/* Fix für den Select-Text */
.q-select .q-field__native span {
  line-height: 1;
  padding-top: 2px;
}

/* Ellipsis for description */
.ellipsis-3-lines {
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-overflow: ellipsis;
  min-height: 4.5em;
}



/* Responsive adjustments */
@media (max-width: 600px) {
  .my-card {
    width: 100%;
    max-width: 350px;
  }
}

/* ==================== */
/* DESCRIPTION SCROLL */
/* ==================== */
.description-scroll {
  max-height: 200px;
  overflow-y: auto;
  padding-right: 8px;
}

/* ==================== */
/* SKILL CHIPS */
/* ==================== */
.q-chip {
  transition: all 0.2s ease;
}
.q-chip:hover {
  transform: scale(1.05);
}

.q-select .q-item {
  text-transform: capitalize;
}

::-webkit-scrollbar {
  width: 6px;
}

::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 3px;
}

::-webkit-scrollbar-thumb {
  background: #888;
  border-radius: 3px;
}

::-webkit-scrollbar-thumb:hover {
  background: #555;
}

.search-field {
  width: 200px;
  transition: width 0.3s ease;
}

.search-field .q-field__control {
  height: 40px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 20px;
}

.search-field .q-field__native {
  color: white;
  padding-left: 8px;
}

.search-field:focus-within {
  width: 250px;
}

/* Kategorie-Filter */
.category-filter .q-field__control {
  height: 40px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 20px;
  color: white;
}

.category-filter .q-field__native {
  color: white;
}

/* Responsive Anpassungen */
@media (max-width: 1024px) {
  .search-field {
    width: 160px;
  }
}

@media (max-width: 768px) {
  .search-field {
    width: 120px;
  }
  
  .category-filter {
    display: none;
  }
}

</style>