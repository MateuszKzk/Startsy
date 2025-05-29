<template>
  <q-layout view="hHh lpR fFf">
    <q-page-container>
      <q-page class="row no-wrap">
        <!-- Conversation List -->
        <div class="col-4" :class="$q.dark.isActive ? 'bg-dark' : 'bg-white'" style="border-right: 1px solid #e0e0e0; height: calc(100vh - 50px);">
          <q-toolbar :class="$q.dark.isActive ? 'bg-dark' : 'bg-primary'">
            <q-toolbar-title class="text-h6" :class="$q.dark.isActive ? 'text-white' : 'text-white'">Messages</q-toolbar-title>
            <q-btn flat round dense icon="search" :color="$q.dark.isActive ? 'white' : 'white'" />
            <q-btn flat round dense icon="add" :color="$q.dark.isActive ? 'white' : 'white'" @click="openNewConversationDialog" class="q-ml-sm" />
          </q-toolbar>

          <q-scroll-area style="height: calc(100% - 50px);">
            <q-list bordered separator :dark="$q.dark.isActive">
              <q-item 
                v-for="conversation in conversations" 
                :key="conversation.id"
                clickable
                @click="selectConversation(conversation.id)"
                :active="activeConversation === conversation.id"
                :active-class="$q.dark.isActive ? 'active-conversation-dark' : 'active-conversation'"
                class="q-py-md"
                :dark="$q.dark.isActive"
              >
                <q-item-section avatar>
                  <q-avatar color="primary" text-color="white" size="48px" font-size="20px">
                    {{ conversation.participant_name?.charAt(0) }}
                    <q-badge v-if="conversation.unread_count > 0" floating color="red" rounded>
                      {{ conversation.unread_count }}
                    </q-badge>
                  </q-avatar>
                </q-item-section>

                <q-item-section>
                  <q-item-label class="text-weight-medium" :class="$q.dark.isActive ? 'text-white' : 'text-black'">{{ conversation.participant_name }}</q-item-label>
                  <q-item-label caption lines="1" :class="$q.dark.isActive ? 'text-grey-4' : 'text-grey-7'">
                    {{ truncate(conversation.last_message, 30) }}
                  </q-item-label>
                </q-item-section>

                <q-item-section side top>
                  <q-item-label caption :class="$q.dark.isActive ? 'text-grey-4' : 'text-grey-6'">
                    {{ formatTime(conversation.last_message_time) }}
                  </q-item-label>
                </q-item-section>
              </q-item>
            </q-list>
          </q-scroll-area>
        </div>

        <!-- Chat Area -->
        <div class="col-8 column" :class="$q.dark.isActive ? 'bg-grey-9' : 'bg-grey-1'" style="height: calc(100vh - 50px);">
          <template v-if="activeConversation">
            <q-toolbar :class="$q.dark.isActive ? 'bg-dark' : 'bg-white'">
              <q-avatar size="48px" color="primary" text-color="white">
                {{ participantName?.charAt(0) }}
              </q-avatar>
              <q-toolbar-title class="q-ml-md">
                <div class="text-h6" :class="$q.dark.isActive ? 'text-white' : 'text-black'">{{ participantName }}</div>
                <div class="text-caption" :class="$q.dark.isActive ? 'text-grey-4' : 'text-grey-6'">
                  <q-badge v-if="isOnline" color="green" rounded />
                  {{ isOnline ? 'Online' : 'Offline' }}
                </div>
              </q-toolbar-title>
              <q-btn flat round dense icon="more_vert" :color="$q.dark.isActive ? 'white' : 'primary'" />
            </q-toolbar>

            <q-scroll-area 
              ref="messagesContainer" 
              class="col"
              :class="$q.dark.isActive ? 'bg-grey-9' : 'bg-grey-1'"
            >
              <div class="q-pa-lg column" style="gap: 16px;">
                <transition-group name="message-fade">
                  <div 
                    v-for="message in messages" 
                    :key="message.id" 
                    class="message-container"
                    :class="isMessageFromCurrentUser(message) ? 'sent' : 'received'"
                  >
                    <div 
                      class="message-bubble"
                      :class="{
                        'bg-primary': isMessageFromCurrentUser(message) && !$q.dark.isActive,
                        'bg-blue-8': isMessageFromCurrentUser(message) && $q.dark.isActive,
                        'bg-grey-3': !isMessageFromCurrentUser(message) && !$q.dark.isActive,
                        'bg-grey-7': !isMessageFromCurrentUser(message) && $q.dark.isActive
                      }"
                    >
                      <div 
                        class="message-content"
                        :class="{
                          'text-white': isMessageFromCurrentUser(message) || $q.dark.isActive,
                          'text-dark': !isMessageFromCurrentUser(message) && !$q.dark.isActive
                        }"
                      >
                        {{ message.content }}
                      </div>
                      <div class="message-meta">
                        <q-icon 
                          v-if="isMessageFromCurrentUser(message) && messageStatus(message)" 
                          :name="messageStatus(message)" 
                          size="14px"
                          class="q-mr-xs"
                          :color="isMessageFromCurrentUser(message) ? ($q.dark.isActive ? 'white' : 'white') : ($q.dark.isActive ? 'grey-4' : 'grey-7')"
                        />
                        <span 
                          class="message-time"
                          :class="{
                            'text-white': isMessageFromCurrentUser(message) || $q.dark.isActive,
                            'text-grey-7': !isMessageFromCurrentUser(message) && !$q.dark.isActive
                          }"
                        >
                          {{ formatMessageTime(message.sent_at) }}
                        </span>
                      </div>
                    </div>
                  </div>
                </transition-group>
              </div>
            </q-scroll-area>

            <q-footer elevated :class="$q.dark.isActive ? 'bg-dark' : 'bg-white'">
              <div class="row items-center q-gutter-sm">
                <q-btn round dense flat icon="insert_emoticon" :color="$q.dark.isActive ? 'white' : 'grey-7'" />
                <q-btn round dense flat icon="attach_file" :color="$q.dark.isActive ? 'white' : 'grey-7'" />
                <q-input 
                  v-model="newMessage" 
                  placeholder="Type a message..." 
                  dense 
                  rounded 
                  outlined 
                  class="col-grow"
                  @keyup.enter="sendMessage"
                  autogrow
                  :dark="$q.dark.isActive"
                  :color="$q.dark.isActive ? 'white' : 'primary'"
                  :input-class="$q.dark.isActive ? 'text-white' : ''"
                >
                  <template v-slot:after>
                    <q-btn 
                      round 
                      dense 
                      flat 
                      icon="send" 
                      :color="$q.dark.isActive ? 'white' : 'primary'" 
                      @click="sendMessage"
                      :disable="!newMessage.trim()"
                    />
                  </template>
                </q-input>
              </div>
            </q-footer>
          </template>

          <!-- Empty State -->
          <div v-else class="flex flex-center column" style="height: 100%;">
            <q-icon name="chat" size="xl" :color="$q.dark.isActive ? 'grey-6' : 'grey-4'" />
            <div class="text-h5" :class="$q.dark.isActive ? 'text-grey-4' : 'text-grey-6'">Select a conversation</div>
            <div class="text-subtitle1" :class="$q.dark.isActive ? 'text-grey-6' : 'text-grey-5'">Choose from your existing conversations</div>
          </div>
        </div>
      </q-page>
    </q-page-container>

    <!-- New Conversation Dialog -->
    <q-dialog v-model="showNewConversationDialog" persistent>
      <q-card :class="$q.dark.isActive ? 'bg-dark' : 'bg-white'" style="min-width: 300px;">
        <q-card-section>
          <div class="text-h6" :class="$q.dark.isActive ? 'text-white' : ''">Start New Conversation</div>
        </q-card-section>
        <q-card-section>
          <q-input
            v-model="newParticipant"
            label="Username or name"
            filled
            dense
            autofocus
            :dark="$q.dark.isActive"
            :color="$q.dark.isActive ? 'white' : 'primary'"
            :input-class="$q.dark.isActive ? 'text-white' : ''"
          />
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancel" v-close-popup :color="$q.dark.isActive ? 'white' : 'primary'" />
          <q-btn flat label="Start" :color="$q.dark.isActive ? 'white' : 'primary'" :disable="!newParticipant.trim()" @click="createConversation" />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-layout>
</template>

<script>
import { ref, onMounted, nextTick, computed } from 'vue'
import { useQuasar, date } from 'quasar'
import { api } from 'boot/axios'
import { useAuthStore } from 'src/stores/auth-store'
import { useRoute } from 'vue-router'

export default {
  name: 'ChatPage',
  
  setup() {
    const $q = useQuasar()
    const authStore = useAuthStore()
    const route = useRoute()

    const conversations = ref([])
    const messages = ref([])
    const activeConversation = ref(null)
    const newMessage = ref('')
    const participantName = ref('')
    const isOnline = ref(false)
    const messagesContainer = ref(null)
    const currentUserId = computed(() => authStore.user?.value?.id)

    const showNewConversationDialog = ref(false)
    const newParticipant = ref('')

   const isMessageFromCurrentUser = (message) => {
  return message.sender_id === currentUserId.value;
};

    const openNewConversationDialog = () => {
      showNewConversationDialog.value = true
      newParticipant.value = ''
    }

    const createConversation = async () => {
      try {
        const usersResponse = await api.get(`/api/users/search?username=${newParticipant.value.trim()}`)
        
        if (usersResponse.data.length === 0) {
          throw new Error('User not found')
        }

        const participantId = usersResponse.data[0].id
        const response = await api.post('/api/conversations', {
          participantId: participantId
        })

        showNewConversationDialog.value = false
        await loadConversations()
        selectConversation(response.data.conversationId)
      } catch (error) {
        $q.notify({
          type: 'negative',
          message: error.response?.data?.message || error.message || 'Failed to create conversation',
          position: 'top',
          timeout: 3000
        })
      }
    }

    const loadConversations = async () => {
      try {
        const response = await api.get('/api/conversations')
        conversations.value = response.data
      } catch (error) {
        $q.notify({
          type: 'negative',
          message: 'Failed to load conversations',
          position: 'top'
        })
        console.log(error);
      }
    }

    const selectConversation = async (conversationId) => {
      activeConversation.value = conversationId
       console.log('Current user ID:', currentUserId.value);

      try {
        const participantResponse = await api.get(`/api/conversations/${conversationId}/participant`)
        participantName.value = participantResponse.data.full_name || participantResponse.data.username

        const messagesResponse = await api.get(`/api/conversations/${conversationId}/messages`)
        messages.value = messagesResponse.data.map(msg => ({
          ...msg,
          sender_id: msg.sender_id // Ensure sender_id is properly set
        }))

        nextTick(() => {
          scrollToBottom()
        })
      } catch (error) {
        $q.notify({
          type: 'negative',
          message: 'Failed to load conversation',
          position: 'top'
        })
        console.log(error);
      }
      
    }

    const sendMessage = async () => {
  if (!newMessage.value.trim() || !authStore.user?.id) return;
  
  const tempId = Date.now();
  const senderId = authStore.user.id; // Jedno źródło prawdy
  
  messages.value.push({
    id: tempId,
    content: newMessage.value,
    sent_at: new Date().toISOString(),
    sender_id: senderId,
    status: 'sending'
  });

      const messageContent = newMessage.value
      newMessage.value = ''

      nextTick(() => {
        scrollToBottom()
      })

      try {
        const response = await api.post(`/api/conversations/${activeConversation.value}/messages`, {
          content: messageContent
        })

        // Update the temporary message with the server response
        const index = messages.value.findIndex(m => m.id === tempId)
        if (index !== -1) {
          messages.value[index] = {
            ...messages.value[index],
            id: response.data.id,
            status: 'sent',
            sender_id: currentUserId.value // Ensure sender_id remains correct
          }
        }

        await loadConversations()
      } catch (error) {
        // Mark message as failed
        const index = messages.value.findIndex(m => m.id === tempId)
        if (index !== -1) {
          messages.value[index].status = 'failed'
        }
        
        $q.notify({
          type: 'negative',
          message: 'Failed to send message',
          position: 'top'
        })
        console.log(error);
      }
    }

    const scrollToBottom = () => {
      if (messagesContainer.value) {
        messagesContainer.value.setScrollPosition('vertical', messagesContainer.value.getScroll().height)
      }
    }

    const formatTime = (timeString) => {
      if (!timeString) return ''
      return date.formatDate(timeString, 'MMM D')
    }

    const formatMessageTime = (timeString) => {
      if (!timeString) return ''
      return date.formatDate(timeString, 'h:mm A')
    }

    const truncate = (text, length) => {
      if (!text) return ''
      return text.length > length ? text.substring(0, length) + '...' : text
    }

    const messageStatus = (message) => {
      if (message.status === 'sending') return 'schedule'
      if (message.status === 'failed') return 'error'
      if (message.read_at) return 'done_all'
      return 'done'
    }

    onMounted(async () => {
  await authStore.initialize(); // Dodaj tę linię
  console.log('Authed user:', authStore.user); // Debug
  
  loadConversations();
  
  if (route.query.conversation) {
    selectConversation(route.query.conversation);
  }
});

    return {
      conversations,
      messages,
      activeConversation,
      newMessage,
      participantName,
      isOnline,
      messagesContainer,
      currentUserId,
      showNewConversationDialog,
      newParticipant,
      isMessageFromCurrentUser,
      openNewConversationDialog,
      createConversation,
      selectConversation,
      sendMessage,
      formatTime,
      formatMessageTime,
      truncate,
      messageStatus
    }
  }
}
</script>

<style scoped>
.active-conversation {
  background-color: rgba(25, 118, 210, 0.08);
}

.active-conversation-dark {
  background-color: rgba(66, 66, 66, 0.5);
}

.message-container {
  display: flex;
  max-width: 80%;
  transition: all 0.3s ease;
}

.message-container.sent {
  margin-left: auto;
  justify-content: flex-end;
}

.message-container.received {
  margin-right: auto;
  justify-content: flex-start;
}

.message-bubble {
  padding: 12px 16px;
  border-radius: 18px;
  position: relative;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
  max-width: 100%;
  word-break: break-word;
}

.message-container.sent .message-bubble {
  border-bottom-right-radius: 4px;
}

.message-container.received .message-bubble {
  border-bottom-left-radius: 4px;
}

.message-meta {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  margin-top: 4px;
  font-size: 0.75rem;
  opacity: 0.8;
}

.message-time {
  margin-left: 4px;
}

.message-fade-enter-active,
.message-fade-leave-active {
  transition: all 0.3s ease;
}

.message-fade-enter-from,
.message-fade-leave-to {
  opacity: 0;
  transform: translateY(10px);
}

.q-scrollarea__thumb {
  background-color: rgba(255, 255, 255, 0.2) !important;
}

.q-scrollarea__thumb:hover {
  background-color: rgba(255, 255, 255, 0.3) !important;
}
</style>