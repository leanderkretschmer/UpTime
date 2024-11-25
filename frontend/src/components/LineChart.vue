<template>
  <div class="relative w-full h-full">
    <svg 
      class="w-full h-full"
      viewBox="0 0 100 100"
      preserveAspectRatio="none"
    >
      <!-- Hintergrund-Grid -->
      <g class="grid">
        <line
          v-for="i in 4"
          :key="`h-${i}`"
          x1="0"
          :y1="i * 20"
          x2="100"
          :y2="i * 20"
          class="stroke-gray-200 dark:stroke-gray-600"
          stroke-width="0.5"
        />
        <line
          v-for="i in 4"
          :key="`v-${i}`"
          :x1="i * 20"
          y1="0"
          :x2="i * 20"
          y2="100"
          class="stroke-gray-200 dark:stroke-gray-600"
          stroke-width="0.5"
        />
      </g>

      <!-- Linie -->
      <path
        :d="linePath"
        :stroke="options.color"
        fill="none"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
      />

      <!-- Gefüllter Bereich unter der Linie -->
      <path
        :d="`${linePath} L 100,100 L 0,100 Z`"
        :fill="options.fillColor"
        opacity="0.1"
      />

      <!-- Datenpunkte -->
      <circle
        v-for="(point, index) in normalizedPoints"
        :key="index"
        :cx="point.x"
        :cy="point.y"
        r="1.5"
        :fill="options.color"
        class="transition-all duration-300"
      />
    </svg>

    <!-- Tooltip -->
    <div
      v-if="hoveredPoint"
      class="absolute bg-white dark:bg-gray-800 shadow-lg rounded-lg px-3 py-2 text-sm transform -translate-x-1/2 -translate-y-full pointer-events-none"
      :style="{
        left: `${hoveredPoint.x}%`,
        top: `${hoveredPoint.y}%`
      }"
    >
      <div class="font-medium text-gray-900 dark:text-white">
        {{ formatValue(hoveredPoint.value) }}
      </div>
      <div class="text-gray-500 dark:text-gray-400">
        {{ formatTime(hoveredPoint.timestamp) }}
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

interface DataPoint {
  timestamp: number
  value: number
}

interface ChartOptions {
  color: string
  fillColor: string
}

const props = defineProps<{
  data: DataPoint[]
  options: ChartOptions
}>()

const hoveredPoint = ref<null | { x: number; y: number; value: number; timestamp: number }>(null)

// Normalisiere die Datenpunkte für SVG-Koordinaten
const normalizedPoints = computed(() => {
  if (!props.data.length) return []

  const minValue = Math.min(...props.data.map(d => d.value))
  const maxValue = Math.max(...props.data.map(d => d.value))
  const valueRange = maxValue - minValue

  return props.data.map((point, index) => {
    const x = (index / (props.data.length - 1)) * 100
    const y = 100 - ((point.value - minValue) / valueRange) * 100
    return { x, y, value: point.value, timestamp: point.timestamp }
  })
})

// Generiere den SVG-Pfad für die Linie
const linePath = computed(() => {
  if (!normalizedPoints.value.length) return ''

  return normalizedPoints.value.reduce((path, point, index) => {
    const command = index === 0 ? 'M' : 'L'
    return `${path} ${command} ${point.x},${point.y}`
  }, '')
})

// Formatierungsfunktionen
const formatValue = (value: number) => `${value.toFixed(1)}%`
const formatTime = (timestamp: number) => {
  return new Date(timestamp).toLocaleTimeString('de-DE', {
    hour: '2-digit',
    minute: '2-digit'
  })
}
</script> 