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
        <v-card class="login-card pa-8" flat width="100%" max-width="450">
          <div class="text-center mb-4">
            <v-icon size="40" color="primary" class="mb-4">mdi-plus-circle</v-icon>
          </div>
          
          <h1 class="text-h4 font-weight-bold text-center mb-2">Welcome back!</h1>
          <p class="text-subtitle-1 text-center mb-8 text-grey-darken-1">Please enter your details</p>
          
          <v-alert v-if="errorMessage" type="error" class="mb-4" density="compact" variant="tonal">
            {{ errorMessage }}
          </v-alert>
          
          <v-form @submit.prevent="handleLogin" ref="form">
            <v-text-field
              v-model="email"
              label="Email"
              variant="outlined"
              density="comfortable"
              bg-color="grey-lighten-4"
              class="mb-4"
              :rules="[v => !!v || 'Email is required', v => /.+@.+\..+/.test(v) || 'Email must be valid']"
              required
            ></v-text-field>
            
            <v-text-field
              v-model="password"
              label="Password"
              variant="outlined"
              density="comfortable"
              bg-color="grey-lighten-4"
              class="mb-2"
              :type="showPassword ? 'text' : 'password'"
              :append-inner-icon="showPassword ? 'mdi-eye' : 'mdi-eye-off'"
              @click:append-inner="showPassword = !showPassword"
              :rules="[v => !!v || 'Password is required']"
              required
            ></v-text-field>
            
            <div class="d-flex align-center justify-space-between mb-6">
              <v-checkbox
                v-model="rememberMe"
                label="Remember for 30 days"
                density="compact"
                hide-details
                color="primary"
              ></v-checkbox>
              
              <a 
                href="#" 
                @click.prevent="handleResetPassword" 
                class="text-decoration-none text-caption text-primary"
              >
                Forgot password?
              </a>
            </div>
            
            <v-btn
              color="black"
              block
              type="submit"
              size="large"
              :loading="loading"
              class="mb-4 text-capitalize font-weight-bold"
              rounded="lg"
              height="48"
            >
              Log In
            </v-btn>
            
            <v-btn
              variant="outlined"
              block
              size="large"
              prepend-icon="mdi-google"
              class="mb-6 text-capitalize font-weight-bold"
              rounded="lg"
              height="48"
              color="grey-darken-1"
              @click="handleGoogleLogin"
              :loading="loading"
              :disabled="loading"
            >
              Log in with Google
            </v-btn>
            
            <div class="text-center">
              <span class="text-grey-darken-1">Don't have an account?</span>
              <router-link to="/register" class="text-decoration-none font-weight-bold ml-1">Sign Up</router-link>
            </div>
          </v-form>
        </v-card>
      </v-col>
    </v-row>
    
    <!-- Dialog Reset Password -->
    <v-dialog v-model="resetDialog" max-width="500px">
      <v-card class="pa-4">
        <v-card-title class="text-h5 font-weight-bold">Reset Password</v-card-title>
        <v-card-text>
          <v-alert v-if="resetMessage" :type="resetMessageType" class="mb-4" density="compact" variant="tonal">
            {{ resetMessage }}
          </v-alert>
          
          <v-text-field
            v-model="resetEmail"
            label="Email"
            variant="outlined"
            density="comfortable"
            bg-color="grey-lighten-4"
            :rules="[v => !!v || 'Email is required', v => /.+@.+\..+/.test(v) || 'Email must be valid']"
          ></v-text-field>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn color="grey-darken-1" variant="text" @click="resetDialog = false">Cancel</v-btn>
          <v-btn 
            color="primary" 
            @click="sendResetPassword"
            :loading="resetLoading"
          >
            Send Reset Link
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-container>
</template>

<script>
import { ref } from 'vue'
import { supabase } from '../supabase'
import { useRouter } from 'vue-router'

export default {
  name: 'LoginView',
  setup() {
    const router = useRouter()
    const email = ref('')
    const password = ref('')
    const showPassword = ref(false)
    const loading = ref(false)
    const errorMessage = ref('')
    const form = ref(null)
    const rememberMe = ref(false)
    
    // Reset password
    const resetDialog = ref(false)
    const resetEmail = ref('')
    const resetLoading = ref(false)
    const resetMessage = ref('')
    const resetMessageType = ref('info')

    const handleLogin = async () => {
      // Validasi form
      const { valid } = await form.value.validate()
      if (!valid) return

      loading.value = true
      errorMessage.value = ''

      try {
        const { data, error } = await supabase.auth.signInWithPassword({
          email: email.value,
          password: password.value
        })

        if (error) throw error

        // Jika berhasil login, router guard akan mengarahkan ke dashboard
        router.push('/dashboard')
      } catch (error) {
        console.error('Error login:', error.message)
        errorMessage.value = error.message || 'Failed to login. Please try again.'
      } finally {
        loading.value = false
      }
    }
    
    const handleGoogleLogin = async () => {
      loading.value = true
      errorMessage.value = ''
      
      try {
        const { data, error } = await supabase.auth.signInWithOAuth({
          provider: 'google',
          options: {
            redirectTo: `${window.location.origin}/dashboard`
          }
        })
        
        if (error) throw error
        
        // Tidak perlu redirect manual karena Supabase akan menangani redirect
        console.log('Redirecting to Google OAuth...', data)
      } catch (error) {
        console.error('Error Google login:', error.message)
        errorMessage.value = error.message || 'Failed to login with Google. Please try again.'
        loading.value = false
      }
    }
    
    const handleResetPassword = () => {
      resetDialog.value = true
      resetEmail.value = email.value // Pre-fill dengan email yang sudah diinput
      resetMessage.value = ''
    }
    
    const sendResetPassword = async () => {
      if (!resetEmail.value || !/.+@.+\..+/.test(resetEmail.value)) {
        resetMessage.value = 'Please enter a valid email'
        resetMessageType.value = 'error'
        return
      }
      
      resetLoading.value = true
      resetMessage.value = ''
      
      try {
        const { error } = await supabase.auth.resetPasswordForEmail(resetEmail.value, {
          redirectTo: window.location.origin + '/reset-password',
        })
        
        if (error) throw error
        
        resetMessage.value = 'Password reset link has been sent to your email'
        resetMessageType.value = 'success'
        
        // Tutup dialog setelah beberapa detik
        setTimeout(() => {
          resetDialog.value = false
        }, 3000)
      } catch (error) {
        console.error('Error reset password:', error.message)
        resetMessage.value = error.message || 'Failed to send reset password link'
        resetMessageType.value = 'error'
      } finally {
        resetLoading.value = false
      }
    }

    return {
      email,
      password,
      showPassword,
      loading,
      errorMessage,
      handleLogin,
      form,
      resetDialog,
      resetEmail,
      resetLoading,
      resetMessage,
      resetMessageType,
      handleResetPassword,
      sendResetPassword,
      rememberMe,
      handleGoogleLogin
    }
  }
}
</script>

<style scoped>
.login-card {
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
