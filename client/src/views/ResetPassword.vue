<template>
  <v-container fluid class="fill-height pa-0">
    <v-row class="fill-height ma-0">
      <!-- Bagian Ilustrasi (Kiri) -->
      <v-col cols="12" md="6" class="bg-grey-lighten-3 d-flex align-center justify-center pa-8 fill-height illustration-col">
        <div class="text-center">
          <v-img
            src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/vuejs/vuejs-original.svg"
            alt="Illustration"
            width="300"
            class="mx-auto mb-8"
          ></v-img>
          <div class="illustration-shapes">
            <div class="shape shape-purple"></div>
            <div class="shape shape-black"></div>
            <div class="shape shape-yellow"></div>
            <div class="shape shape-orange"></div>
          </div>
        </div>
      </v-col>
      
      <!-- Bagian Form (Kanan) -->
      <v-col cols="12" md="6" class="d-flex align-center justify-center pa-8">
        <v-card class="reset-card pa-8" flat width="100%" max-width="450">
          <div class="text-center mb-4">
            <v-icon size="40" color="primary" class="mb-4">mdi-lock-reset</v-icon>
          </div>
          
          <h1 class="text-h4 font-weight-bold text-center mb-2">Reset Password</h1>
          <p class="text-subtitle-1 text-center mb-8 text-grey-darken-1">Please enter your new password</p>
          
          <v-alert v-if="errorMessage" type="error" class="mb-4" density="compact" variant="tonal">
            {{ errorMessage }}
          </v-alert>
          
          <v-alert v-if="successMessage" type="success" class="mb-4" density="compact" variant="tonal">
            {{ successMessage }}
          </v-alert>
          
          <v-form @submit.prevent="handleResetPassword" ref="form">
            <v-text-field
              v-model="password"
              label="New Password"
              variant="outlined"
              density="comfortable"
              bg-color="grey-lighten-4"
              class="mb-4"
              :type="showPassword ? 'text' : 'password'"
              :append-inner-icon="showPassword ? 'mdi-eye' : 'mdi-eye-off'"
              @click:append-inner="showPassword = !showPassword"
              :rules="[v => !!v || 'Password is required', v => v.length >= 6 || 'Password must be at least 6 characters']"
              required
            ></v-text-field>
            
            <v-text-field
              v-model="confirmPassword"
              label="Confirm New Password"
              variant="outlined"
              density="comfortable"
              bg-color="grey-lighten-4"
              class="mb-6"
              :type="showConfirmPassword ? 'text' : 'password'"
              :append-inner-icon="showConfirmPassword ? 'mdi-eye' : 'mdi-eye-off'"
              @click:append-inner="showConfirmPassword = !showConfirmPassword"
              :rules="[
                v => !!v || 'Confirm password is required',
                v => v === password || 'Passwords do not match'
              ]"
              required
            ></v-text-field>
            
            <v-btn
              color="black"
              block
              type="submit"
              size="large"
              :loading="loading"
              class="mb-6 text-capitalize font-weight-bold"
              rounded="lg"
              height="48"
            >
              Reset Password
            </v-btn>
            
            <div class="text-center">
              <router-link to="/" class="text-decoration-none font-weight-bold">Back to login</router-link>
            </div>
          </v-form>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import { ref, onMounted } from 'vue'
import { supabase } from '../supabase'
import { useRouter } from 'vue-router'

export default {
  name: 'ResetPasswordView',
  setup() {
    const router = useRouter()
    const password = ref('')
    const confirmPassword = ref('')
    const showPassword = ref(false)
    const showConfirmPassword = ref(false)
    const loading = ref(false)
    const errorMessage = ref('')
    const successMessage = ref('')
    const form = ref(null)

    onMounted(() => {
      // Cek apakah ada hash fragment di URL yang menunjukkan reset password
      const hash = window.location.hash
      if (!hash || !hash.includes('type=recovery')) {
        errorMessage.value = 'Invalid or expired password reset link'
      }
    })

    const handleResetPassword = async () => {
      // Validasi form
      const { valid } = await form.value.validate()
      if (!valid) return

      // Cek apakah password dan konfirmasi password cocok
      if (password.value !== confirmPassword.value) {
        errorMessage.value = 'Passwords do not match'
        return
      }

      loading.value = true
      errorMessage.value = ''
      successMessage.value = ''

      try {
        // Update password di Supabase
        const { error } = await supabase.auth.updateUser({
          password: password.value
        })

        if (error) throw error

        successMessage.value = 'Password has been reset successfully. You will be redirected to login page.'
        
        // Redirect ke halaman login setelah beberapa detik
        setTimeout(() => {
          router.push('/')
        }, 3000)
      } catch (error) {
        console.error('Error reset password:', error.message)
        errorMessage.value = error.message || 'Failed to reset password. Please try again.'
      } finally {
        loading.value = false
      }
    }

    return {
      password,
      confirmPassword,
      showPassword,
      showConfirmPassword,
      loading,
      errorMessage,
      successMessage,
      handleResetPassword,
      form
    }
  }
}
</script>

<style scoped>
.reset-card {
  border-radius: 16px;
}

.illustration-col {
  position: relative;
  overflow: hidden;
}

.illustration-shapes {
  position: relative;
  width: 300px;
  height: 300px;
  margin: 0 auto;
}

.shape {
  position: absolute;
  border-radius: 12px;
}

.shape-purple {
  width: 120px;
  height: 180px;
  background-color: #6C63FF;
  left: 20px;
  top: 20px;
  z-index: 1;
}

.shape-black {
  width: 80px;
  height: 120px;
  background-color: #222;
  left: 160px;
  top: 60px;
  z-index: 2;
}

.shape-yellow {
  width: 100px;
  height: 100px;
  background-color: #FFCE00;
  border-radius: 50px;
  right: 40px;
  top: 40px;
  z-index: 3;
}

.shape-orange {
  width: 140px;
  height: 70px;
  background-color: #FF7A00;
  border-radius: 70px 70px 0 0;
  left: 80px;
  bottom: 20px;
  z-index: 4;
}
</style>
