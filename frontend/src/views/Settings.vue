<template>
  <div class="space-y-6">
    <!-- Theme Settings -->
    <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-sm p-6">
      <h2 class="text-lg font-semibold text-gray-900 dark:text-white mb-6">Erscheinungsbild</h2>
      <div class="flex items-center justify-between">
        <div>
          <h3 class="text-sm font-medium text-gray-700 dark:text-gray-300">Dark Mode</h3>
          <p class="text-sm text-gray-500 dark:text-gray-400">Dunkles Erscheinungsbild aktivieren</p>
        </div>
        <button 
          @click="toggleTheme"
          class="min-w-[44px] min-h-[44px] p-2 text-gray-500 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-gray-700 rounded-xl"
        >
          <SunIcon v-if="isDark" class="h-6 w-6" />
          <MoonIcon v-else class="h-6 w-6" />
        </button>
      </div>
    </div>

    <!-- Simulierte Systeme -->
    <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-sm p-6">
      <div class="flex justify-between items-center mb-6">
        <h2 class="text-lg font-semibold text-gray-900 dark:text-white">Simulierte Systeme</h2>
        <Switch
          v-model="simulationEnabled"
          class="relative inline-flex h-6 w-11 items-center rounded-full"
          :class="simulationEnabled ? 'bg-blue-600' : 'bg-gray-200 dark:bg-gray-700'"
        >
          <span class="sr-only">Simulation aktivieren</span>
          <span
            class="inline-block h-4 w-4 transform rounded-full bg-white transition"
            :class="simulationEnabled ? 'translate-x-6' : 'translate-x-1'"
          />
        </Switch>
      </div>

      <div class="space-y-4">
        <!-- System Liste -->
        <div v-for="system in simulatedSystems" :key="system.id"
             class="flex items-center justify-between p-4 bg-gray-50 dark:bg-gray-700/50 rounded-xl">
          <div>
            <h3 class="text-sm font-medium text-gray-900 dark:text-white">{{ system.name }}</h3>
            <p class="text-sm text-gray-500 dark:text-gray-400">{{ system.ip }}</p>
          </div>
          <div class="flex items-center space-x-4">
            <StatusBadge :status="system.status" />
            <button @click="removeSystem(system.id)"
                    class="min-w-[44px] min-h-[44px] text-red-600 dark:text-red-400 hover:text-red-700 dark:hover:text-red-300">
              <TrashIcon class="h-5 w-5" />
            </button>
          </div>
        </div>

        <!-- Add System Form -->
        <form @submit.prevent="addSystem" class="mt-6 space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Systemname
            </label>
            <input 
              v-model="newSystem.name"
              type="text"
              required
              class="w-full min-h-[44px] px-4 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-xl text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 dark:focus:ring-blue-400"
              placeholder="z.B. Webserver"
            >
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              IP-Adresse
            </label>
            <input 
              v-model="newSystem.ip"
              type="text"
              required
              class="w-full min-h-[44px] px-4 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-xl text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 dark:focus:ring-blue-400"
              placeholder="z.B. 192.168.1.100"
            >
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Status
            </label>
            <select 
              v-model="newSystem.status"
              class="w-full min-h-[44px] px-4 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-xl text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 dark:focus:ring-blue-400"
            >
              <option value="online">Online (mit Ping-Simulation)</option>
              <option value="offline">Offline (mit Fehlermeldung)</option>
            </select>
          </div>
          <button 
            type="submit"
            class="w-full min-h-[44px] px-4 py-2 bg-blue-600 text-white rounded-xl hover:bg-blue-700 focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
          >
            System hinzufügen
          </button>
        </form>
      </div>
    </div>

    <!-- Simulierte Services -->
    <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-sm p-6">
      <h2 class="text-lg font-semibold text-gray-900 dark:text-white mb-6">Simulierte Services</h2>
      
      <div class="space-y-4">
        <!-- Service Liste -->
        <div v-for="service in simulatedServices" :key="service.id"
             class="flex items-center justify-between p-4 bg-gray-50 dark:bg-gray-700/50 rounded-xl">
          <div>
            <h3 class="text-sm font-medium text-gray-900 dark:text-white">{{ service.name }}</h3>
            <p class="text-sm text-gray-500 dark:text-gray-400">Port: {{ service.port }}</p>
          </div>
          <div class="flex items-center space-x-4">
            <StatusBadge :status="service.status" />
            <button @click="removeService(service.id)"
                    class="min-w-[44px] min-h-[44px] text-red-600 dark:text-red-400 hover:text-red-700 dark:hover:text-red-300">
              <TrashIcon class="h-5 w-5" />
            </button>
          </div>
        </div>

        <!-- Add Service Form -->
        <form @submit.prevent="addService" class="mt-6 space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Servicename
            </label>
            <input 
              v-model="newService.name"
              type="text"
              required
              class="w-full min-h-[44px] px-4 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-xl text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 dark:focus:ring-blue-400"
              placeholder="z.B. HTTP"
            >
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Port
            </label>
            <input 
              v-model="newService.port"
              type="number"
              required
              class="w-full min-h-[44px] px-4 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-xl text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 dark:focus:ring-blue-400"
              placeholder="z.B. 80"
            >
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Status
            </label>
            <select 
              v-model="newService.status"
              class="w-full min-h-[44px] px-4 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-xl text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 dark:focus:ring-blue-400"
            >
              <option value="online">Online</option>
              <option value="offline">Offline</option>
            </select>
          </div>
          <button 
            type="submit"
            class="w-full min-h-[44px] px-4 py-2 bg-blue-600 text-white rounded-xl hover:bg-blue-700 focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
          >
            Service hinzufügen
          </button>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { Switch } from '@headlessui/vue'
import { SunIcon, MoonIcon, TrashIcon } from '@heroicons/vue/24/outline'
import StatusBadge from '@/components/StatusBadge.vue'
import { useSystemStore } from '@/stores/system'

const systemStore = useSystemStore()
const isDark = ref(document.documentElement.classList.contains('dark'))
const simulationEnabled = ref(true)

const simulatedSystems = ref([
  {
    id: 1,
    name: 'Webserver',
    ip: '192.168.1.100',
    status: 'online'
  },
  {
    id: 2,
    name: 'Database Server',
    ip: '192.168.1.101',
    status: 'offline'
  }
])

const simulatedServices = ref([
  {
    id: 1,
    name: 'HTTP',
    port: 80,
    status: 'online'
  },
  {
    id: 2,
    name: 'PostgreSQL',
    port: 5432,
    status: 'offline'
  }
])

const newSystem = ref({
  name: '',
  ip: '',
  status: 'online'
})

const newService = ref({
  name: '',
  port: '',
  status: 'online'
})

const toggleTheme = () => {
  isDark.value = !isDark.value
  document.documentElement.classList.toggle('dark')
  localStorage.setItem('theme', isDark.value ? 'dark' : 'light')
}

const addSystem = () => {
  simulatedSystems.value.push({
    id: Date.now(),
    ...newSystem.value
  })
  newSystem.value = {
    name: '',
    ip: '',
    status: 'online'
  }
}

const removeSystem = (id: number) => {
  simulatedSystems.value = simulatedSystems.value.filter(s => s.id !== id)
}

const addService = () => {
  simulatedServices.value.push({
    id: Date.now(),
    ...newService.value
  })
  newService.value = {
    name: '',
    port: '',
    status: 'online'
  }
}

const removeService = (id: number) => {
  simulatedServices.value = simulatedServices.value.filter(s => s.id !== id)
}
</script> 