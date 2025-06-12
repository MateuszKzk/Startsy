<template>
  <link href="https://cdn.jsdelivr.net/npm/@mdi/font@6.9.96/css/materialdesignicons.min.css" rel="stylesheet">
  
  <q-layout view="hHh lpR fFf" class="bg-grey-2">
    <!-- ==================== -->
    <!-- HEADER SECTION -->
    <!-- ==================== -->
    <q-header elevated class="bg-dark text-white">
      <q-toolbar class="q-py-sm">
        <!-- Logo -->
        <q-btn flat dense to="/" class="q-mr-sm no-underline">
          <q-toolbar-title class="text-white text-left flex items-center">
            <q-icon name="rocket" size="md" class="q-mr-sm text-primary" />
            <span class="text-weight-bold">Startsy</span>
          </q-toolbar-title>
        </q-btn>

        <q-space />

        <!-- Navigation for logged in users -->
        <template v-if="currentUser">
          <q-tabs 
            v-model="currentTab" 
            shrink 
            stretch 
            inline-label
            class="text-white"
            active-color="primary"
            indicator-color="primary"
          >
            <q-route-tab name="startups" label="Startups" to="/startups" icon="business" />
            <q-route-tab name="chat" label="Chat" to="/chat" icon="chat" />
          </q-tabs>

          <q-space />

          <!-- Search and Filter -->
          <div class="row items-center q-gutter-sm q-pr-md">
            <!-- Search Field -->
            <q-input
              v-model="searchQuery"
              outlined
              dense
              placeholder="Search startups..."
              class="search-field bg-grey-9"
              clearable
              dark
              borderless
              input-class="text-white"
              @keyup.enter="performSearch"
              @clear="performSearch"
            >
              <template v-slot:prepend>
                <q-icon name="search" color="primary" @click="performSearch" />
              </template>
            </q-input>

            <!-- Category Filter -->
            <q-select
              v-model="selectedCategory"
              :options="categories"
              outlined
              dense
              label="Filter by category"
              class="category-filter bg-grey-9"
              dark
              borderless
              clearable
              emit-value
              map-options
              style="min-width: 180px"
              @update:model-value="performSearch"
            >
              <template v-slot:prepend>
                <q-icon name="filter_list" color="primary" />
              </template>
              <template v-slot:append>
                <q-icon 
                  v-if="selectedCategory" 
                  name="close" 
                  color="primary"
                  class="cursor-pointer" 
                  @click.stop="selectedCategory = null" 
                />
              </template>
            </q-select>
          </div>

          <q-space />

          <!-- User Dropdown -->
          <q-btn-dropdown 
            flat 
            stretch 
            :label="userInitials" 
            class="text-white"
            dropdown-icon="expand_more"
          >
            <q-list class="q-py-sm" style="min-width: 200px">
              <q-item clickable v-close-popup to="/profile" class="q-pa-sm">
                <q-item-section avatar>
                  <q-icon name="account_circle" color="primary" />
                </q-item-section>
                <q-item-section>
                  <q-item-label>My Profile</q-item-label>
                </q-item-section>
              </q-item>

              <q-item clickable v-close-popup to="/settings" class="q-pa-sm">
                <q-item-section avatar>
                  <q-icon name="settings" color="primary" />
                </q-item-section>
                <q-item-section>
                  <q-item-label>Settings</q-item-label>
                </q-item-section>
              </q-item>

              <q-separator class="q-my-xs" />

              <q-item clickable v-close-popup @click="logout" class="q-pa-sm">
                <q-item-section avatar>
                  <q-icon name="logout" color="negative" />
                </q-item-section>
                <q-item-section>
                  <q-item-label class="text-negative">Logout</q-item-label>
                </q-item-section>
              </q-item>
            </q-list>
          </q-btn-dropdown>
        </template>

        <!-- Login Button for guests -->
        <q-btn 
          v-else 
          outline 
          color="primary" 
          label="Login" 
          :to="{ name: 'login' }" 
          class="q-px-md"
        />
      </q-toolbar>
    </q-header>

    <!-- ==================== -->
    <!-- MAIN CONTENT SECTION -->
    <!-- ==================== -->
    <q-page-container>
      <q-page class="q-pa-lg">
        <!-- Startup Cards Grid -->
        <div class="row q-col-gutter-lg">
          <!-- Add Startup Card -->
          <div class="col-12 col-sm-6 col-md-4 col-lg-3">
            <q-card 
              class="my-card cursor-pointer bg-grey-1"
              flat
              bordered
              @click="showAddDialog = true"
            >
              <q-card-section class="flex flex-center column" style="height: 200px;">
                <q-icon name="add" size="xl" color="grey-7" />
                <div class="text-h6 q-mt-md text-grey-7">Add New Startup</div>
              </q-card-section>
            </q-card>
          </div>

          <!-- Startup Cards -->
          <div 
            v-for="startup in filteredStartups" 
            :key="startup.id" 
            class="col-12 col-sm-6 col-md-4 col-lg-3"
          >
            <q-card 
              class="my-card text-dark cursor-pointer"
              :class="{'bg-dark text-white': $q.dark.isActive}"
              :style="`background-color: ${startup.color || ($q.dark.isActive ? '#1e1e1e' : '#ffffff')}`"
              flat
              bordered
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
                  <q-icon name="schedule" size="sm" :color="$q.dark.isActive ? 'grey-4' : 'grey-7'" />
                  <span class="text-caption" :class="{'text-grey-4': $q.dark.isActive, 'text-grey-7': !$q.dark.isActive}">
                    {{ formatDate(startup.created_at) }}
                  </span>
                </div>
                <div class="row items-center q-gutter-sm q-mt-sm">
                  <q-icon name="people" size="sm" :color="$q.dark.isActive ? 'grey-4' : 'grey-7'" />
                  <span class="text-caption" :class="{'text-grey-4': $q.dark.isActive, 'text-grey-7': !$q.dark.isActive}">
                    {{ startup.members_count || 0 }} members
                  </span>
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
        </div>

        <!-- Add Startup Dialog -->
        <q-dialog v-model="showAddDialog" persistent>
  <q-card :class="{'bg-grey-9': $q.dark.isActive}" style="min-width: 500px; max-width: 600px;">
    <!-- Header -->
    <q-card-section class="row items-center q-pb-none">
      <div class="text-h6 text-weight-bold" :class="{'text-white': $q.dark.isActive}">Add New Startup</div>
      <q-space />
      <q-btn 
        icon="close" 
        flat 
        round 
        dense 
        v-close-popup 
        :color="$q.dark.isActive ? 'white' : 'dark'" 
        @click="resetForm"
      />
    </q-card-section>

    <q-separator />

    <!-- Form Content -->
    <q-card-section class="scroll" style="max-height: 70vh; overflow-y: auto;">
      <q-form @submit="submitStartup" class="q-gutter-md">
        <!-- Startup Name -->
        <q-input 
          v-model="form.name" 
          label="Startup Name *" 
          outlined
          :dark="$q.dark.isActive"
          :class="{'bg-grey-8': $q.dark.isActive}"
          :rules="[val => !!val || 'Field is required']"
          lazy-rules
        />

        <!-- Description -->
        <q-input 
          v-model="form.description" 
          label="Description *" 
          type="textarea" 
          outlined
          :dark="$q.dark.isActive"
          :class="{'bg-grey-8': $q.dark.isActive}"
          :rules="[val => !!val || 'Field is required']"
          lazy-rules
          rows="3"
        />

        <!-- Skill Selection - Improved -->
        <div>
          <div class="text-subtitle2 q-mb-sm" :class="{'text-white': $q.dark.isActive}">Required Skills *</div>
          <q-input 
            v-model="skillSearch" 
            outlined 
            dense 
            placeholder="Search skills..." 
            class="q-mb-sm" 
            clearable
            :dark="$q.dark.isActive"
            :class="{'bg-grey-8': $q.dark.isActive}"
          >
            <template v-slot:prepend>
              <q-icon name="search" :color="$q.dark.isActive ? 'primary' : 'dark'" />
            </template>
          </q-input>
          
          <div 
            class="q-gutter-sm q-mb-sm" 
            style="max-height: 150px; overflow-y: auto;"
            :class="{'border-grey': !$q.dark.isActive, 'border-dark': $q.dark.isActive, 'rounded-borders': true}"
          >
            <q-chip 
              v-for="skill in filteredSkills" 
              :key="skill.id" 
              clickable
              :color="form.required_skills.includes(skill.id) ? 'primary' : ($q.dark.isActive ? 'grey-7' : 'grey-4')"
              :text-color="form.required_skills.includes(skill.id) ? 'white' : ($q.dark.isActive ? 'white' : 'dark')"
              @click="toggleSkill(skill.id)"
              class="q-ma-xs"
            >
              {{ skill.name }}
              <q-icon v-if="form.required_skills.includes(skill.id)" name="check" class="q-ml-xs" />
            </q-chip>
          </div>
          <div v-if="form.required_skills.length === 0" class="text-caption text-negative">
            Please select at least one skill
          </div>
        </div>

        <!-- Contact Information - Improved -->
        <div>
          <div class="text-subtitle2 text-weight-medium q-mb-sm" :class="{'text-white': $q.dark.isActive}">
            Contact Information *
          </div>
          
          <div 
            class="q-gutter-y-md"
            :class="{'border-grey': !$q.dark.isActive, 'border-dark': $q.dark.isActive, 'rounded-borders': true, 'q-pa-sm': true}"
          >
            <div v-for="(contact, index) in form.contacts" :key="index" class="row items-center no-wrap q-gutter-sm">
              <q-select
                v-model="contact.type"
                :options="contactOptions"
                outlined
                dense
                style="min-width: 120px;"
                :dark="$q.dark.isActive"
                :class="{'bg-grey-8': $q.dark.isActive}"
                :rules="[val => !!val || 'Required']"
                lazy-rules
              />
              <q-input
                v-model="contact.value"
                outlined
                dense
                class="col"
                :dark="$q.dark.isActive"
                :class="{'bg-grey-8': $q.dark.isActive}"
                :rules="[
                  val => !!val || 'Required',
                  val => contact.type !== 'email' || isValidEmail(val) || 'Invalid email'
                ]"
                lazy-rules
              />
              <q-btn
                icon="remove"
                round
                dense
                flat
                :color="$q.dark.isActive ? 'white' : 'dark'"
                @click="removeContact(index)"
                v-if="form.contacts.length > 1"
              />
            </div>
            
            <q-btn
              icon="add"
              label="Add Contact"
              dense
              flat
              color="primary"
              @click="addContact"
              class="full-width"
            />
          </div>
        </div>

        <!-- Form Actions -->
        <q-card-actions align="right" class="q-px-none">
          <q-btn 
            flat 
            label="Cancel" 
            :color="$q.dark.isActive ? 'white' : 'dark'" 
            v-close-popup 
            @click="resetForm"
          />
          <q-btn 
            color="primary" 
            label="Add Startup" 
            type="submit"
            :disable="form.required_skills.length === 0"
          />
        </q-card-actions>
      </q-form>
    </q-card-section>
  </q-card>
</q-dialog>

        <!-- Startup Details Dialog -->
        <q-dialog v-model="showDetailsDialog" persistent>
          <q-card :class="{'bg-grey-9': $q.dark.isActive}" style="width: 800px; max-width: 95vw;">
            <q-card-section class="row items-center q-pb-none">
              <div class="text-h5 text-weight-bold" :class="{'text-white': $q.dark.isActive}">{{ selectedStartup.name }}</div>
              <q-space />
              <q-btn icon="close" flat round dense v-close-popup :color="$q.dark.isActive ? 'white' : 'dark'" />
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
                  <q-card flat bordered :class="{'bg-grey-8': $q.dark.isActive}">
                    <q-card-section>
                      <div class="text-subtitle1 text-weight-bold q-mb-sm" :class="{'text-white': $q.dark.isActive}">Description</div>
                      <p class="text-body1 q-mt-sm" :class="{'text-white': $q.dark.isActive}">{{ selectedStartup.description }}</p>
                    </q-card-section>

                    <q-card-section>
                      <div class="text-subtitle1 text-weight-bold q-mt-lg q-mb-sm" :class="{'text-white': $q.dark.isActive}">Required Skills</div>
                      <div class="q-gutter-sm q-mb-sm">
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
                  <q-card flat bordered :class="{'bg-grey-8': $q.dark.isActive}">
                    <q-list bordered class="rounded-borders">
                      <q-item :class="{'bg-grey-7': $q.dark.isActive}">
                        <q-item-section avatar>
                          <q-icon name="event" color="primary" />
                        </q-item-section>
                        <q-item-section>
                          <q-item-label :class="{'text-white': $q.dark.isActive}">Founded</q-item-label>
                          <q-item-label caption :class="{'text-grey-4': $q.dark.isActive}">{{ formatDate(selectedStartup.created_at) }}</q-item-label>
                        </q-item-section>
                      </q-item>

                      <q-separator />

                      <q-item :class="{'bg-grey-7': $q.dark.isActive}">
                        <q-item-section avatar>
                          <q-icon name="people" color="primary" />
                        </q-item-section>
                        <q-item-section>
                          <q-item-label :class="{'text-white': $q.dark.isActive}">Members</q-item-label>
                          <q-item-label caption :class="{'text-grey-4': $q.dark.isActive}">{{ selectedStartup.members_count || 0 }}</q-item-label>
                        </q-item-section>
                      </q-item>

                      <q-separator />

                      <template v-for="(contact, index) in parsedContacts" :key="`${index}-${contact.type}`">
                        <q-item :class="{'bg-grey-7': $q.dark.isActive}">
                          <q-item-section avatar>
                            <q-icon :name="getContactIcon(contact.type)" color="primary" />
                          </q-item-section>
                          <q-item-section>
                            <q-item-label :class="{'text-white': $q.dark.isActive}">{{ getContactLabel(contact.type) }}</q-item-label>
                            <q-item-label caption :class="{'text-grey-4': $q.dark.isActive}">
                              <a v-if="contact.type === 'email'" :href="`mailto:${contact.value}`" class="text-primary">{{ contact.value }}</a>
                              <a v-else-if="contact.type === 'phone'" :href="`tel:${contact.value}`" class="text-primary">{{ contact.value }}</a>
                              <span v-else>{{ contact.value }}</span>
                            </q-item-label>
                          </q-item-section>
                        </q-item>
                        <q-separator v-if="index < parsedContacts.length - 1" />
                      </template>
                    </q-list>

                    <q-card-actions vertical class="q-mt-md">
                      <q-btn 
                        color="primary" 
                        label="Join Startup" 
                        @click="joinStartup" 
                        class="q-mb-sm"
                        no-caps
                      />
                    </q-card-actions>
                  </q-card>
                </div>
              </div>
            </q-card-section>
          </q-card>
        </q-dialog>

        <!-- Search Results Dialog -->
        <q-dialog v-model="showSearchResults" persistent>
          <q-card :class="{'bg-grey-9': $q.dark.isActive}" style="width: 800px; max-width: 95vw;">
            <q-card-section class="row items-center q-pb-none">
              <div class="text-h5 text-weight-bold" :class="{'text-white': $q.dark.isActive}">Search Results</div>
              <q-space />
              <q-btn icon="close" flat round dense v-close-popup :color="$q.dark.isActive ? 'white' : 'dark'" />
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
                    :class="{'bg-dark text-white': $q.dark.isActive}"
                    :style="`background-color: ${startup.color || ($q.dark.isActive ? '#1e1e1e' : '#ffffff')}`"
                    flat
                    bordered
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
                        <q-icon name="schedule" size="sm" :color="$q.dark.isActive ? 'grey-4' : 'grey-7'" />
                        <span class="text-caption" :class="{'text-grey-4': $q.dark.isActive, 'text-grey-7': !$q.dark.isActive}">
                          {{ formatDate(startup.created_at) }}
                        </span>
                      </div>
                      <div class="row items-center q-gutter-sm q-mt-sm">
                        <q-icon name="people" size="sm" :color="$q.dark.isActive ? 'grey-4' : 'grey-7'" />
                        <span class="text-caption" :class="{'text-grey-4': $q.dark.isActive, 'text-grey-7': !$q.dark.isActive}">
                          {{ startup.members_count || 0 }} members
                        </span>
                      </div>
                    </q-card-section>
                  </q-card>
                </div>
              </div>
            </q-card-section>
          </q-card>
        </q-dialog>
      </q-page>
    </q-page-container>

    <!-- ==================== -->
    <!-- FOOTER SECTION -->
    <!-- ==================== -->
    <q-footer class="bg-grey-9 text-white text-center q-pa-md">
      <div class="text-caption">
        © 2024 Startsy - All Rights Reserved
      </div>
    </q-footer>
  </q-layout>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { useQuasar } from 'quasar'
import { useRouter } from 'vue-router'
import axios from 'axios'
import { watch } from 'vue'
import { debounce } from 'src/utils/debounce'

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
  { label: 'Web Development', value: 'Web Development' },
  { label: 'Backend', value: 'Backend' },
  { label: 'Database', value: 'Database' },
  { label: 'DevOps', value: 'DevOps' },
  { label: 'Mobile', value: 'Mobile' },
  { label: 'Data Science', value: 'Data Science' },
  { label: 'AI/ML', value: 'AI/ML' },
  { label: 'Systems', value: 'Systems' },
  { label: 'Version Control', value: 'Version Control' },
  { label: 'Security', value: 'Security' },
  { label: 'Emerging Tech', value: 'Emerging Tech' },
  { label: 'Embedded Systems', value: 'Embedded Systems' },
  { label: 'Game Dev', value: 'GameDev' }
]);
   
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
  // Remove duplicates by ID
  const uniqueMap = new Map();
  startups.value.forEach(item => {
    if (!uniqueMap.has(item.id)) {
      uniqueMap.set(item.id, item);
    }
  });
  return Array.from(uniqueMap.values());
});

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
    const params = new URLSearchParams();
    if (searchQuery.value) params.append('search', searchQuery.value);
    if (selectedCategory.value) params.append('category', selectedCategory.value);
    
    const res = await api.get(`/startups/filtered?${params.toString()}`);
    console.log('Startups data:', res.data);
    
    // Check for duplicate IDs
    const ids = res.data.map(s => s.id);
    const uniqueIds = [...new Set(ids)];
    if (ids.length !== uniqueIds.length) {
      console.warn('Duplicate startup IDs found!');
    }
    
    startups.value = res.data;
  } catch (err) {
    console.error('API Error:', err.response?.data || err.message);
    $q.notify({
      type: 'negative',
      message: err.response?.data?.message || 'Failed to load startups',
      caption: process.env.DEV ? err.message : '',
      position: 'top',
      timeout: 5000
    });
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

const performSearch = debounce(async () => {
  await fetchStartups();
  
  // Feedback für den Nutzer
  if (searchQuery.value || selectedCategory.value) {
    const resultCount = filteredStartups.value.length;
    const message = resultCount === 0 
      ? 'No matching startups found' 
      : `Found ${resultCount} ${resultCount === 1 ? 'result' : 'results'}`;
    
    $q.notify({
      message,
      color: resultCount > 0 ? 'positive' : 'warning',
      position: 'top',
      timeout: 1000
    });
  }
}, 300);


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
  width: 100%;
  min-height: 280px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
  border: 1px solid rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

.body--dark .my-card {
  border: 1px solid rgba(255, 255, 255, 0.12);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
  background-color: #1e1e1e;
}

.my-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
  border-color: var(--q-primary);
}

/* Add Startup Card */
.my-card.bg-grey-1:hover {
  border-color: var(--q-primary);
  background-color: rgba(var(--q-primary-rgb), 0.05) !important;
}

.body--dark .my-card.bg-grey-1 {
  background-color: #2a2a2a !important;
}

/* ==================== */
/* FORM CONTROLS */
/* ==================== */
.contact-type-select .q-field__control,
.contact-value-input .q-field__control,
.search-field .q-field__control,
.category-filter .q-field__control {
  height: 40px;
  border-radius: 8px;
}

.body--dark .q-field__control {
  background-color: #2a2a2a !important;
}

/* ==================== */
/* LAYOUT UTILITIES */
/* ==================== */
.row.items-center.no-wrap {
  align-items: center;
}

/* Fix select text alignment */
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

/* ==================== */
/* SCROLLABLE CONTENT */
/* ==================== */
.description-scroll {
  max-height: 200px;
  overflow-y: auto;
  padding-right: 8px;
}

/* Custom scrollbar */
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

.body--dark ::-webkit-scrollbar-track {
  background: #2e2e2e;
}

.body--dark ::-webkit-scrollbar-thumb {
  background: #555;
}

/* ==================== */
/* SKILL CHIPS */
/* ==================== */
.q-chip {
  transition: all 0.2s ease;
  border-radius: 6px;
}

.q-chip:hover {
  transform: scale(1.05);
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
}

.body--dark .q-chip:not(.bg-primary) {
  background-color: #333 !important;
  color: white !important;
}

/* ==================== */
/* SEARCH & FILTER */
/* ==================== */
.search-field {
  width: 220px;
  transition: width 0.3s ease;
}

.search-field .q-field__control {
  background: rgba(255, 255, 255, 0.1);
  border-radius: 20px;
  transition: all 0.3s ease;
}

.search-field .q-field__native {
  color: white;
  padding-left: 8px;
}

.search-field:focus-within {
  width: 280px;
}

.search-field:focus-within .q-field__control {
  background: rgba(255, 255, 255, 0.15);
}

/* Category filter */
.category-filter .q-field__control {
  background: rgba(255, 255, 255, 0.1);
  border-radius: 20px;
  color: white;
}

.category-filter .q-field__native {
  color: white;
}

/* ==================== */
/* DIALOGS */
/* ==================== */
.q-dialog__inner .q-card {
  border-radius: 12px;
  overflow: hidden;
}

.q-dialog__inner .q-card-section {
  padding: 20px;
}

.body--dark .q-dialog__inner .q-card {
  background-color: #1e1e1e;
}

/* ==================== */
/* TEXT & TYPOGRAPHY */
/* ==================== */
.text-subtitle2 {
  line-height: 1.4;
}

.text-caption {
  font-size: 0.8rem;
}

.body--dark .text-dark {
  color: white !important;
}

/* ==================== */
/* RESPONSIVE ADJUSTMENTS */
/* ==================== */
@media (max-width: 1024px) {
  .search-field {
    width: 180px;
  }
  
  .search-field:focus-within {
    width: 220px;
  }
}

@media (max-width: 768px) {
  .search-field {
    width: 140px;
  }
  
  .category-filter {
    display: none;
  }
}

@media (max-width: 600px) {
  .search-field {
    width: 120px;
  }
  
  .my-card {
    min-height: 250px;
  }
}
</style>