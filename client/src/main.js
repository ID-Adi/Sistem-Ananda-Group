import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'

// Vuetify
import 'vuetify/styles'
import { createVuetify } from 'vuetify'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'
import '@mdi/font/css/materialdesignicons.css'
import { aliases, mdi } from 'vuetify/iconsets/mdi'

// Custom CSS
import './assets/main.css'

const vuetify = createVuetify({
  components,
  directives,
  theme: {
    defaultTheme: 'light',
    themes: {
      light: {
        colors: {
          primary: '#FBBA09',        // Ananda Group primary color (amber)
          secondary: '#F59E0B',      // Secondary amber tone
          accent: '#D97706',         // Darker amber for accents
          error: '#EF4444',
          info: '#3B82F6',
          success: '#10B981',
          warning: '#F59E0B',
          background: '#F5F5F5',
          surface: '#FFFFFF',
        },
      },
      dark: {
        colors: {
          primary: '#FBBA09',        // Ananda Group primary color (amber)
          secondary: '#F59E0B',      // Secondary amber tone
          accent: '#D97706',         // Darker amber for accents
          error: '#F87171',
          info: '#60A5FA',
          success: '#34D399',
          warning: '#FBBF24',
          background: '#121212',
          surface: '#1E1E1E',
        },
      },
    },
  },
  icons: {
    defaultSet: 'mdi',
    aliases,
    sets: {
      mdi,
    }
  },
})

const app = createApp(App)

app.use(createPinia())
app.use(router)
app.use(vuetify)

app.mount('#app')
