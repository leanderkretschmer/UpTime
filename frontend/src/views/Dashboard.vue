<template>
  <div class="space-y-6">
    <!-- Hauptwidget -->
    <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-sm p-6">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <!-- Status Overview -->
        <div class="space-y-4">
          <h2 class="text-lg font-semibold text-gray-900 dark:text-white">System Status</h2>
          <div class="grid grid-cols-2 gap-4">
            <div class="bg-green-50 dark:bg-green-900/20 p-4 rounded-xl">
              <div class="text-2xl font-bold text-green-600 dark:text-green-400">{{ onlineCount }}</div>
              <div class="text-sm text-green-700 dark:text-green-500">Online</div>
            </div>
            <div class="bg-red-50 dark:bg-red-900/20 p-4 rounded-xl">
              <div class="text-2xl font-bold text-red-600 dark:text-red-400">{{ offlineCount }}</div>
              <div class="text-sm text-red-700 dark:text-red-500">Offline</div>
            </div>
          </div>
        </div>

        <!-- Uptime Graph -->
        <div class="space-y-4">
          <h2 class="text-lg font-semibold text-gray-900 dark:text-white">Uptime</h2>
          <div class="h-32 bg-gray-50 dark:bg-gray-700/50 rounded-xl p-4">
            <LineChart 
              :data="uptimeData" 
              :options="{ color: '#10B981', fillColor: '#10B98120' }"
            />
          </div>
        </div>

        <!-- Error Graph -->
        <div class="space-y-4">
          <h2 class="text-lg font-semibold text-gray-900 dark:text-white">Fehler</h2>
          <div class="h-32 bg-gray-50 dark:bg-gray-700/50 rounded-xl p-4">
            <LineChart 
              :data="errorData" 
              :options="{ color: '#EF4444', fillColor: '#EF444420' }"
            />
          </div>
        </div>
      </div>
    </div>

    <!-- Server Widgets -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div v-for="server in servers" :key="server.id" 
           class="bg-white dark:bg-gray-800 rounded-2xl shadow-sm p-6 space-y-4">
        <div class="flex justify-between items-start">
          <div>
            <h3 class="text-lg font-semibold text-gray-900 dark:text-white">{{ server.name }}</h3>
            <p class="text-sm text-gray-500 dark:text-gray-400">{{ server.ip }}</p>
          </div>
          <StatusBadge :status="server.status" />
        </div>
        
        <!-- Ping Display für Online Server -->
        <div v-if="server.status === 'online'" class="space-y-2">
          <div class="flex justify-between items-center">
            <span class="text-sm text-gray-500 dark:text-gray-400">Ping</span>
            <span class="text-sm font-medium text-gray-900 dark:text-white">{{ server.ping }}ms</span>
          </div>
          <div class="h-2 bg-gray-100 dark:bg-gray-700 rounded-full overflow-hidden">
            <div class="h-full bg-green-500 dark:bg-green-400 transition-all duration-500"
                 :style="{ width: `${Math.min(server.ping / 15 * 100, 100)}%` }">
            </div>
          </div>
        </div>

        <!-- Fehlermeldung für Offline Server -->
        <div v-else class="text-sm text-red-600 dark:text-red-400 bg-red-50 dark:bg-red-900/20 p-3 rounded-xl">
          {{ server.error }}
        </div>

        <!-- Services -->
        <div v-if="server.services?.length" class="space-y-2">
          <h4 class="text-sm font-medium text-gray-700 dark:text-gray-300">Services</h4>
          <div class="space-y-2">
            <div v-for="service in server.services" :key="service.id"
                 class="flex justify-between items-center p-2 bg-gray-50 dark:bg-gray-700/50 rounded-lg">
              <span class="text-sm text-gray-600 dark:text-gray-400">{{ service.name }}</span>
              <StatusBadge :status="service.status" small />
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { useSystemStore } from '@/stores/system'
import StatusBadge from '@/components/StatusBadge.vue'
import LineChart from '@/components/LineChart.vue'

const systemStore = useSystemStore()
const servers = ref([
  {
    id: 1,
    name: 'Webserver',
    ip: '192.168.1.100',
    status: 'online',
    ping: 5,
    services: [
      { id: 1, name: 'HTTP', status: 'online' },
      { id: 2, name: 'HTTPS', status: 'online' }
    ]
  },
  {
    id: 2,
    name: 'Database Server',
    ip: '192.168.1.101',
    status: 'offline',
    error: 'Connection refused: No route to host',
    services: [
      { id: 3, name: 'PostgreSQL', status: 'offline' }
    ]
  }
])

// Statistiken
const onlineCount = ref(0)
const offlineCount = ref(0)
const uptimeData = ref([])
const errorData = ref([])

// Simulierte Daten für Graphen
const generateGraphData = () => {
  const now = Date.now()
  const data = []
  for (let i = 0; i < 24; i++) {
    data.push({
      timestamp: now - (23 - i) * 3600000,
      value: Math.random() * 100
    })
  }
  return data
}

// Ping Simulation
let pingInterval: number
const simulatePing = () => {
  const server = servers.value[0]
  if (server && server.status === 'online') {
    server.ping = Math.floor(Math.random() * 13) + 2 // 2-15ms
  }
}

// Statistiken aktualisieren
const updateStats = () => {
  onlineCount.value = servers.value.filter(s => s.status === 'online').length
  offlineCount.value = servers.value.filter(s => s.status === 'offline').length
  
  // Graphen aktualisieren
  uptimeData.value = generateGraphData()
  errorData.value = generateGraphData()
}

onMounted(() => {
  updateStats()
  pingInterval = setInterval(() => {
    simulatePing()
    updateStats()
  }, 2000)
})

onUnmounted(() => {
  clearInterval(pingInterval)
})
</script> 