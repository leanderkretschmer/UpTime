<template>
  <span 
    class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
    :class="[
      small ? 'text-xs' : 'text-sm',
      status === 'online' 
        ? 'bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-400'
        : 'bg-red-100 text-red-800 dark:bg-red-900/20 dark:text-red-400'
    ]"
  >
    <span 
      class="w-1.5 h-1.5 rounded-full mr-1.5"
      :class="[
        status === 'online' ? 'bg-green-400' : 'bg-red-400'
      ]"
    />
    {{ status === 'online' ? 'Online' : 'Offline' }}
  </span>
</template>

<script setup lang="ts">
defineProps<{
  status: 'online' | 'offline'
  small?: boolean
}>()
</script> 