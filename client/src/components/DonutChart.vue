<template>
  <div class="chart-container">
    <Doughnut :data="chartData" :options="chartOptions" />
  </div>
</template>

<script>
import { Doughnut } from 'vue-chartjs'
import { Chart as ChartJS, ArcElement, Tooltip, Legend } from 'chart.js'

ChartJS.register(ArcElement, Tooltip, Legend)

export default {
  name: 'DonutChart',
  components: {
    Doughnut
  },
  props: {
    chartData: {
      type: Object,
      required: true
    },
    chartOptions: {
      type: Object,
      default: () => ({
        responsive: true,
        maintainAspectRatio: false,
        cutout: '70%',
        plugins: {
          legend: {
            display: false
          },
          tooltip: {
            backgroundColor: '#1E1E2D',
            titleFont: {
              size: 13
            },
            bodyFont: {
              size: 13
            },
            padding: 10,
            cornerRadius: 8,
            displayColors: true,
            callbacks: {
              label: function(context) {
                let label = context.label || '';
                let value = context.formattedValue;
                let percentage = context.parsed + '%';
                return `${label}: ${value} (${percentage})`;
              }
            }
          }
        }
      })
    }
  }
}
</script>

<style scoped>
.chart-container {
  position: relative;
  height: 300px;
  width: 100%;
}
</style>
