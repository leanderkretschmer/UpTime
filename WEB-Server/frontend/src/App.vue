<template>
  <div class="min-h-screen bg-gray-100 dark:bg-gray-900">
    <!-- Navigation -->
    <nav class="bg-white dark:bg-gray-800 shadow-sm">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
          <div class="flex">
            <div class="flex-shrink-0 flex items-center">
              <img class="h-8 w-auto" src="@/assets/logo.svg" alt="UpTime" />
            </div>
            <div class="hidden sm:ml-6 sm:flex sm:space-x-8">
              <router-link 
                v-for="item in navigation" 
                :key="item.name"
                :to="item.href"
                class="nav-link"
                :class="{ 'active': currentRoute === item.href }"
              >
                {{ item.name }}
              </router-link>
            </div>
          </div>
          
          <div class="flex items-center">
            <button @click="toggleTheme" class="p-2">
              <sun-icon v-if="isDark" class="h-6 w-6" />
              <moon-icon v-else class="h-6 w-6" />
            </button>
            <div class="ml-3 relative">
              <UserMenu />
            </div>
          </div>
        </div>
      </div>
    </nav>

    <!-- Main Content -->
    <main class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
      <router-view />
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { SunIcon, MoonIcon } from '@heroicons/vue/outline'
import UserMenu from '@/components/UserMenu.vue'

const isDark = ref(false)
const currentRoute = ref('')

const navigation = [
  { name: 'Dashboard', href: '/' },
  { name: 'Systeme', href: '/systems' },
  { name: 'Services', href: '/services' },
  { name: 'Einstellungen', href: '/settings' }
]

const toggleTheme = () => {
  isDark.value = !isDark.value
  document.documentElement.classList.toggle('dark')
}

onMounted(() => {
  const route = useRoute()
  currentRoute.value = route.path
})
</script> 