<template>
  <div class="fixed inset-0 z-50 overflow-y-auto" @click="$emit('close')">
    <!-- Backdrop -->
    <div class="fixed inset-0 bg-black bg-opacity-25 backdrop-blur-sm"></div>

    <!-- Modal -->
    <div class="flex min-h-full items-center justify-center p-4">
      <div 
        class="relative bg-white dark:bg-gray-800 rounded-2xl shadow-xl max-w-lg w-full p-6"
        @click.stop
      >
        <!-- Header -->
        <div class="mb-6">
          <h2 class="text-lg font-semibold text-gray-900 dark:text-white">
            <slot name="title"></slot>
          </h2>
        </div>

        <!-- Content -->
        <div>
          <slot></slot>
        </div>

        <!-- Close Button -->
        <button 
          @click="$emit('close')"
          class="absolute top-4 right-4 min-w-[44px] min-h-[44px] p-2 text-gray-400 hover:text-gray-500 dark:hover:text-gray-300"
        >
          <XMarkIcon class="h-6 w-6" />
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { XMarkIcon } from '@heroicons/vue/24/outline'

defineEmits(['close'])
</script>

<style scoped>
.backdrop-blur-sm {
  backdrop-filter: blur(4px);
}
</style> 