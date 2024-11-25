<template>
  <div class="space-y-6">
    <!-- Status Card -->
    <StatusCard 
      :systems="systems"
      :services="services"
    />
    
    <!-- Systems Overview -->
    <div class="bg-white dark:bg-gray-800 shadow rounded-lg">
      <div class="px-4 py-5 sm:p-6">
        <h3 class="text-lg font-medium text-gray-900 dark:text-gray-100">
          Systeme
        </h3>
        <div class="mt-4 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          <SystemCard 
            v-for="system in systems"
            :key="system.id"
            :system="system"
          />
        </div>
      </div>
    </div>

    <!-- Services Overview -->
    <div class="bg-white dark:bg-gray-800 shadow rounded-lg">
      <div class="px-4 py-5 sm:p-6">
        <h3 class="text-lg font-medium text-gray-900 dark:text-gray-100">
          Services
        </h3>
        <div class="mt-4 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          <ServiceCard 
            v-for="service in services"
            :key="service.id"
            :service="service"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import StatusCard from '@/components/StatusCard.vue'
import SystemCard from '@/components/SystemCard.vue'
import ServiceCard from '@/components/ServiceCard.vue'
import { useSystemStore } from '@/stores/system'
import { useServiceStore } from '@/stores/service'

const systemStore = useSystemStore()
const serviceStore = useServiceStore()

const systems = ref([])
const services = ref([])

onMounted(async () => {
  systems.value = await systemStore.fetchSystems()
  services.value = await serviceStore.fetchServices()
})
</script> 