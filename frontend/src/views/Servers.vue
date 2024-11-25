<template>
  <div class="space-y-6">
    <!-- Server Liste -->
    <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-sm p-6">
      <div class="flex justify-between items-center mb-6">
        <h2 class="text-lg font-semibold text-gray-900 dark:text-white">Server Verwaltung</h2>
        <button 
          @click="showAddServer = true"
          class="min-h-[44px] px-4 py-2 bg-blue-600 text-white rounded-xl hover:bg-blue-700 focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
        >
          <PlusIcon class="h-5 w-5 inline-block mr-2" />
          Server hinzufügen
        </button>
      </div>

      <!-- Server Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div v-for="server in servers" :key="server.id" 
             class="bg-gray-50 dark:bg-gray-700/50 rounded-xl p-6 space-y-4">
          <div class="flex justify-between items-start">
            <div>
              <h3 class="text-lg font-medium text-gray-900 dark:text-white">{{ server.name }}</h3>
              <p class="text-sm text-gray-500 dark:text-gray-400">{{ server.ip }}</p>
            </div>
            <div class="flex space-x-2">
              <button 
                @click="editServer(server)"
                class="min-w-[44px] min-h-[44px] p-2 text-gray-500 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-600 rounded-lg"
              >
                <PencilIcon class="h-5 w-5" />
              </button>
              <button 
                @click="deleteServer(server.id)"
                class="min-w-[44px] min-h-[44px] p-2 text-red-500 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-lg"
              >
                <TrashIcon class="h-5 w-5" />
              </button>
            </div>
          </div>

          <!-- Services -->
          <div class="space-y-3">
            <div class="flex justify-between items-center">
              <h4 class="text-sm font-medium text-gray-700 dark:text-gray-300">Services</h4>
              <button 
                @click="addService(server)"
                class="min-w-[44px] min-h-[44px] p-2 text-blue-600 dark:text-blue-400 hover:bg-blue-50 dark:hover:bg-blue-900/20 rounded-lg"
              >
                <PlusIcon class="h-5 w-5" />
              </button>
            </div>
            <div class="space-y-2">
              <div v-for="service in server.services" :key="service.id"
                   class="flex items-center justify-between p-3 bg-white dark:bg-gray-800 rounded-lg">
                <div>
                  <span class="text-sm font-medium text-gray-900 dark:text-white">{{ service.name }}</span>
                  <span class="text-sm text-gray-500 dark:text-gray-400 ml-2">Port {{ service.port }}</span>
                </div>
                <div class="flex items-center space-x-2">
                  <StatusBadge :status="service.status" small />
                  <button 
                    @click="highlightService(service)"
                    class="min-w-[44px] min-h-[44px] p-2"
                    :class="service.highlighted 
                      ? 'text-yellow-500 dark:text-yellow-400' 
                      : 'text-gray-400 dark:text-gray-500'"
                  >
                    <StarIcon class="h-5 w-5" />
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Server Modal -->
    <Modal v-if="showAddServer" @close="showAddServer = false">
      <template #title>
        {{ editingServer ? 'Server bearbeiten' : 'Server hinzufügen' }}
      </template>
      <form @submit.prevent="saveServer" class="space-y-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
            Servername
          </label>
          <input 
            v-model="serverForm.name"
            type="text"
            required
            class="w-full min-h-[44px] px-4 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-xl"
          >
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
            IP-Adresse
          </label>
          <input 
            v-model="serverForm.ip"
            type="text"
            required
            class="w-full min-h-[44px] px-4 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-xl"
          >
        </div>
        <div class="flex justify-end space-x-3">
          <button 
            type="button"
            @click="showAddServer = false"
            class="min-h-[44px] px-4 py-2 border border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-300 rounded-xl"
          >
            Abbrechen
          </button>
          <button 
            type="submit"
            class="min-h-[44px] px-4 py-2 bg-blue-600 text-white rounded-xl hover:bg-blue-700"
          >
            {{ editingServer ? 'Speichern' : 'Hinzufügen' }}
          </button>
        </div>
      </form>
    </Modal>

    <!-- Service Modal -->
    <Modal v-if="showAddService" @close="showAddService = false">
      <template #title>Service hinzufügen</template>
      <form @submit.prevent="saveService" class="space-y-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
            Servicename
          </label>
          <input 
            v-model="serviceForm.name"
            type="text"
            required
            class="w-full min-h-[44px] px-4 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-xl"
          >
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
            Port
          </label>
          <input 
            v-model="serviceForm.port"
            type="number"
            required
            class="w-full min-h-[44px] px-4 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-xl"
          >
        </div>
        <div class="flex justify-end space-x-3">
          <button 
            type="button"
            @click="showAddService = false"
            class="min-h-[44px] px-4 py-2 border border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-300 rounded-xl"
          >
            Abbrechen
          </button>
          <button 
            type="submit"
            class="min-h-[44px] px-4 py-2 bg-blue-600 text-white rounded-xl hover:bg-blue-700"
          >
            Hinzufügen
          </button>
        </div>
      </form>
    </Modal>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { PlusIcon, PencilIcon, TrashIcon, StarIcon } from '@heroicons/vue/24/outline'
import StatusBadge from '@/components/StatusBadge.vue'
import Modal from '@/components/Modal.vue'

const servers = ref([
  {
    id: 1,
    name: 'Webserver',
    ip: '192.168.1.100',
    services: [
      { id: 1, name: 'HTTP', port: 80, status: 'online', highlighted: true },
      { id: 2, name: 'HTTPS', port: 443, status: 'online', highlighted: false }
    ]
  },
  {
    id: 2,
    name: 'Database Server',
    ip: '192.168.1.101',
    services: [
      { id: 3, name: 'PostgreSQL', port: 5432, status: 'offline', highlighted: true }
    ]
  }
])

const showAddServer = ref(false)
const showAddService = ref(false)
const editingServer = ref(null)
const selectedServer = ref(null)

const serverForm = ref({
  name: '',
  ip: ''
})

const serviceForm = ref({
  name: '',
  port: ''
})

const editServer = (server) => {
  editingServer.value = server
  serverForm.value = { ...server }
  showAddServer.value = true
}

const saveServer = () => {
  if (editingServer.value) {
    const index = servers.value.findIndex(s => s.id === editingServer.value.id)
    servers.value[index] = { ...servers.value[index], ...serverForm.value }
  } else {
    servers.value.push({
      id: Date.now(),
      ...serverForm.value,
      services: []
    })
  }
  showAddServer.value = false
  editingServer.value = null
  serverForm.value = { name: '', ip: '' }
}

const deleteServer = (id) => {
  servers.value = servers.value.filter(s => s.id !== id)
}

const addService = (server) => {
  selectedServer.value = server
  showAddService.value = true
}

const saveService = () => {
  if (selectedServer.value) {
    const server = servers.value.find(s => s.id === selectedServer.value.id)
    server.services.push({
      id: Date.now(),
      ...serviceForm.value,
      status: 'online',
      highlighted: false
    })
  }
  showAddService.value = false
  selectedServer.value = null
  serviceForm.value = { name: '', port: '' }
}

const highlightService = (service) => {
  service.highlighted = !service.highlighted
}
</script> 