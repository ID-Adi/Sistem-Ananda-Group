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
        <v-card class="register-card pa-8" flat width="100%" max-width="450">
          <div class="text-center mb-4">
            <v-icon size="40" color="primary" class="mb-4">mdi-plus-circle</v-icon>
          </div>
          
          <h1 class="text-h4 font-weight-bold text-center mb-2">Create an account</h1>
          <p class="text-subtitle-1 text-center mb-8 text-grey-darken-1">Please enter your details</p>
          
          <v-alert v-if="errorMessage" type="error" class="mb-4" density="compact" variant="tonal">
            {{ errorMessage }}
          </v-alert>
          
          <v-alert v-if="successMessage" type="success" class="mb-4" density="compact" variant="tonal">
            {{ successMessage }}
          </v-alert>
          
          <v-form @submit.prevent="handleRegister" ref="form">
            <v-text-field
              v-model="fullName"
              label="Full Name"
              variant="outlined"
              density="comfortable"
              bg-color="grey-lighten-4"
              class="mb-4"
              :rules="[v => !!v || 'Full name is required']"
              required
            ></v-text-field>
            
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
              class="mb-4"
              :type="showPassword ? 'text' : 'password'"
              :append-inner-icon="showPassword ? 'mdi-eye' : 'mdi-eye-off'"
              @click:append-inner="showPassword = !showPassword"
              :rules="[v => !!v || 'Password is required', v => v.length >= 6 || 'Password must be at least 6 characters']"
              required
            ></v-text-field>
            
            <v-text-field
              v-model="confirmPassword"
              label="Confirm Password"
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
              class="mb-4 text-capitalize font-weight-bold"
              rounded="lg"
              height="48"
            >
              Create Account
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
              @click="handleGoogleSignUp"
              :loading="loading"
              :disabled="loading"
            >
              Sign up with Google
            </v-btn>
            
            <div class="text-center">
              <span class="text-grey-darken-1">Already have an account?</span>
              <router-link to="/" class="text-decoration-none font-weight-bold ml-1">Log In</router-link>
            </div>
          </v-form>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import { ref } from 'vue'
import { supabase } from '../supabase'
import { useRouter } from 'vue-router'

export default {
  name: 'RegisterView',
  setup() {
    const router = useRouter()
    const fullName = ref('')
    const email = ref('')
    const password = ref('')
    const confirmPassword = ref('')
    const showPassword = ref(false)
    const showConfirmPassword = ref(false)
    const loading = ref(false)
    const errorMessage = ref('')
    const successMessage = ref('')
    const form = ref(null)

    const handleRegister = async () => {
      // Validasi form
      const { valid } = await form.value.validate()
      if (!valid) return

      // Validasi password dan konfirmasi password
      if (password.value !== confirmPassword.value) {
        errorMessage.value = 'Passwords do not match'
        return
      }

      loading.value = true
      errorMessage.value = ''
      successMessage.value = ''

      try {
        // Register user baru di Supabase
        const { data, error } = await supabase.auth.signUp({
          email: email.value,
          password: password.value,
          options: {
            data: {
              full_name: fullName.value
            },
            emailRedirectTo: window.location.origin + '/dashboard'
          }
        })

        if (error) throw error

        successMessage.value = 'Registration successful! Please check your email to confirm your account.'
        
        // Reset form setelah berhasil register
        fullName.value = ''
        email.value = ''
        password.value = ''
        confirmPassword.value = ''
        
        // Redirect ke dashboard jika tidak perlu konfirmasi email
        if (data?.user && !data?.user?.identities?.[0]?.identity_data?.email_verified) {
          setTimeout(() => {
            router.push('/dashboard')
          }, 3000)
        }
      } catch (error) {
        console.error('Error register:', error.message)
        errorMessage.value = error.message || 'Failed to register. Please try again.'
      } finally {
        loading.value = false
      }
    }
    
    const handleGoogleSignUp = async () => {
      loading.value = true
      errorMessage.value = ''
      successMessage.value = ''
      
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
        console.error('Error Google sign up:', error.message)
        errorMessage.value = error.message || 'Failed to sign up with Google. Please try again.'
        loading.value = false
      }
    }

    return {
      fullName,
      email,
      password,
      confirmPassword,
      showPassword,
      showConfirmPassword,
      loading,
      errorMessage,
      successMessage,
      handleRegister,
      handleGoogleSignUp,
      form
    }
  }
}
</script>

<style scoped>
.register-card {
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
