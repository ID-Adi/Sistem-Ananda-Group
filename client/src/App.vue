<template>
  <v-app>
    <v-main>
      <router-view />
    </v-main>
    
    <!-- Snackbar untuk notifikasi -->
    <v-snackbar
      v-model="snackbar.show"
      :color="snackbar.color"
      :timeout="snackbar.timeout"
    >
      {{ snackbar.text }}
      
      <template v-slot:actions>
        <v-btn
          variant="text"
          @click="snackbar.show = false"
        >
          Tutup
        </v-btn>
      </template>
    </v-snackbar>
  </v-app>
</template>

<script>
import { supabase } from './supabase'
import { useRouter } from 'vue-router'
import { onMounted, ref, provide } from 'vue'
import { isEmailAllowed } from './utils/emailAccess'

export default {
  name: 'App',
  setup() {
    const router = useRouter()
    const user = ref(null)
    const snackbar = ref({
      show: false,
      text: '',
      color: 'success',
      timeout: 3000
    })

    // Menyediakan fungsi showNotification untuk komponen lain
    const showNotification = (text, color = 'success', timeout = 3000) => {
      snackbar.value = {
        show: true,
        text,
        color,
        timeout
      }
    }
    
    provide('showNotification', showNotification)

    onMounted(async () => {
      // Cek status login saat aplikasi dimuat
      const { data } = await supabase.auth.getSession()
      user.value = data?.session?.user || null

      // Jika user sudah login, periksa apakah emailnya diizinkan
      if (user.value) {
        const allowed = await isEmailAllowed(user.value.email)
        if (!allowed) {
          // Jika email tidak diizinkan, logout
          await supabase.auth.signOut()
          user.value = null
          showNotification('Akun Anda tidak diizinkan mengakses aplikasi ini', 'error', 5000)
          router.push('/')
        }
      }

      // Subscribe ke perubahan auth state
      supabase.auth.onAuthStateChange(async (event, session) => {
        console.log('Auth state changed:', event)
        
        if (event === 'SIGNED_IN') {
          user.value = session?.user || null
          
          console.log('User signed in:', user.value.email)
          
          // Periksa apakah email diizinkan
          const allowed = await isEmailAllowed(user.value.email)
          console.log('Email allowed?', allowed)
          
          if (!allowed) {
            // Jika email tidak diizinkan, logout
            await supabase.auth.signOut()
            user.value = null
            showNotification('Akun Anda tidak diizinkan mengakses aplikasi ini', 'error', 5000)
            router.push('/')
            return
          }
          
          showNotification('Login berhasil', 'success')
          router.push('/dashboard')
        } else if (event === 'SIGNED_OUT') {
          user.value = null
          showNotification('Logout berhasil', 'info')
          router.push('/')
        } else if (event === 'PASSWORD_RECOVERY') {
          router.push('/reset-password')
        } else if (event === 'USER_UPDATED') {
          showNotification('Profil pengguna diperbarui', 'success')
        }
      })
    })

    return {
      user,
      snackbar,
      showNotification
    }
  }
}
</script>

<style>
html, body {
  margin: 0;
  padding: 0;
  height: 100%;
  width: 100%;
}
</style>
