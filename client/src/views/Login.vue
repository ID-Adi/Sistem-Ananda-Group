<template>
  <v-container fluid class="fill-height pa-0 bg-gradient">
    <v-row class="fill-height ma-0 justify-center align-center">
      <v-col cols="12" sm="8" md="6" lg="5" xl="4">
        <v-card class="mx-auto rounded-xl login-card" elevation="10" max-width="700">
          <v-row>
            <v-col cols="12" class="pa-10">
              <div class="text-center mb-8">
                <div class="text-h5 font-weight-bold ananda-text">ANANDA GROUP</div>
              </div>

              <div>
                <div class="flex-grow-1">
                  <v-alert v-if="errorMessage" type="error" class="mb-4" density="compact" variant="tonal">
                    {{ errorMessage }}
                  </v-alert>

                  <v-form @submit.prevent="handleLogin" ref="form">
                    <v-text-field
                      v-model="email"
                      label="Email"
                      variant="outlined"
                      density="comfortable"
                      bg-color="white"
                      class="mb-4 modern-input"
                      placeholder="example@gmail.com"
                      :rules="[v => !!v || 'Email is required', v => /.+@.+\..+/.test(v) || 'Email must be valid']"
                      required
                    ></v-text-field>
                    
                    <v-text-field
                      v-model="password"
                      label="Password"
                      variant="outlined"
                      density="comfortable"
                      bg-color="white"
                      class="mb-8 modern-input"
                      placeholder="8+ characters"
                      :type="showPassword ? 'text' : 'password'"
                      :append-inner-icon="showPassword ? 'mdi-eye' : 'mdi-eye-off'"
                      @click:append-inner="showPassword = !showPassword"
                      :rules="[v => !!v || 'Password is required']"
                      required
                    ></v-text-field>
                    
                    <v-btn
                      block
                      size="large"
                      :loading="loading"
                      class="mb-5 text-capitalize font-weight-bold ananda-gradient-btn"
                      rounded="xl"
                      height="56"
                      @click="handleLogin"
                    >
                      {{ isSignUp ? 'Sign Up' : 'Login' }}
                    </v-btn>

                    <v-btn
                      variant="outlined"
                      block
                      size="large"
                      color="success"
                      class="mb-8 text-capitalize font-weight-bold google-btn"
                      rounded="xl"
                      height="56"
                      @click="handleGoogleLogin"
                      :loading="loading"
                      :disabled="loading"
                    >
                      <div class="google-icon-wrapper mr-2">
                        <svg class="google-icon" width="18" height="18" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
                          <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
                          <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
                          <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
                          <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
                        </svg>
                      </div>
                      <span class="text-success">{{ isSignUp ? 'Sign up with Google' : 'Login with Google' }}</span>
                    </v-btn>

                    <div class="text-center">
                      <span class="text-grey-darken-1">
                        {{ isSignUp ? 'Already have an account?' : 'Don\'t have an account?' }}
                      </span>
                      <a 
                        href="#" 
                        @click.prevent="toggleSignUp" 
                        class="text-decoration-none font-weight-bold ml-1 ananda-text"
                      >
                        {{ isSignUp ? 'Sign In' : 'Sign Up' }}
                      </a>
                    </div>
                  </v-form>
                </div>
              </div>
            </v-col>
          </v-row>
        </v-card>
      </v-col>
    </v-row>

    <!-- Dialog Reset Password -->
    <v-dialog v-model="resetDialog" max-width="500px">
      <v-card class="pa-6 rounded-xl" elevation="10">
        <v-card-title class="text-h5 font-weight-bold ananda-text">Reset Password</v-card-title>
        <v-card-text>
          <v-alert v-if="resetMessage" :type="resetMessageType" class="mb-4" density="compact" variant="tonal">
            {{ resetMessage }}
          </v-alert>
          
          <v-text-field
            v-model="resetEmail"
            label="Email"
            variant="outlined"
            density="comfortable"
            bg-color="white"
            class="mb-4 modern-input"
            :rules="[v => !!v || 'Email is required', v => /.+@.+\..+/.test(v) || 'Email must be valid']"
          ></v-text-field>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn color="grey-darken-1" variant="text" @click="resetDialog = false">Cancel</v-btn>
          <v-btn 
            class="ananda-gradient-btn"
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
    const isSignUp = ref(false)
    
    // Reset password
    const resetDialog = ref(false)
    const resetEmail = ref('')
    const resetLoading = ref(false)
    const resetMessage = ref('')
    const resetMessageType = ref('info')

    const toggleSignUp = () => {
      isSignUp.value = !isSignUp.value
      errorMessage.value = ''
    }

    const handleLogin = async () => {
      // Validasi form
      const { valid } = await form.value.validate()
      if (!valid) return

      loading.value = true
      errorMessage.value = ''

      try {
        if (isSignUp.value) {
          // Sign up
          const { data, error } = await supabase.auth.signUp({
            email: email.value,
            password: password.value
          })

          if (error) throw error

          errorMessage.value = ''
          alert('Registration successful! Please check your email to verify your account.')
        } else {
          // Login
          const { data, error } = await supabase.auth.signInWithPassword({
            email: email.value,
            password: password.value
          })

          if (error) throw error

          // Jika berhasil login, router guard akan mengarahkan ke dashboard
          router.push('/dashboard')
        }
      } catch (error) {
        console.error('Error:', error.message)
        errorMessage.value = error.message || 'Failed to process your request. Please try again.'
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
      } catch (error) {
        console.error('Error login dengan Google:', error.message)
        errorMessage.value = error.message || 'Failed to login with Google. Please try again.'
      } finally {
        loading.value = false
      }
    }
    
    const handleResetPassword = () => {
      resetDialog.value = true
      resetEmail.value = email.value
      resetMessage.value = ''
    }
    
    const sendResetPassword = async () => {
      if (!resetEmail.value || !resetEmail.value.includes('@')) {
        resetMessage.value = 'Please enter a valid email'
        resetMessageType.value = 'error'
        return
      }
      
      resetLoading.value = true
      resetMessage.value = ''
      
      try {
        const { error } = await supabase.auth.resetPasswordForEmail(resetEmail.value, {
          redirectTo: `${window.location.origin}/reset-password`
        })
        
        if (error) throw error
        
        resetMessage.value = 'Password reset link has been sent to your email'
        resetMessageType.value = 'success'
      } catch (error) {
        console.error('Error reset password:', error.message)
        resetMessage.value = error.message || 'Failed to send reset link. Please try again.'
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
      form,
      isSignUp,
      toggleSignUp,
      handleLogin,
      handleGoogleLogin,
      // Reset password
      resetDialog,
      resetEmail,
      resetLoading,
      resetMessage,
      resetMessageType,
      handleResetPassword,
      sendResetPassword
    }
  }
}
</script>

<style scoped>
.bg-gradient {
  background: linear-gradient(135deg, #FBBA09 0%, #F59E0B 100%);
}

.login-card {
  overflow: hidden;
  border: none;
  backdrop-filter: blur(10px);
  background-color: rgba(255, 255, 255, 0.95);
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1) !important;
  transition: all 0.3s ease;
}

.login-card:hover {
  box-shadow: 0 15px 50px rgba(0, 0, 0, 0.15) !important;
  transform: translateY(-5px);
}

.ananda-text {
  background: linear-gradient(90deg, #FBBA09 0%, #F59E0B 100%);
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
}

.ananda-gradient-btn {
  background: linear-gradient(90deg, #FBBA09 0%, #F59E0B 100%) !important;
  color: white !important;
  box-shadow: 0 4px 15px rgba(245, 158, 11, 0.4) !important;
  transition: all 0.3s ease;
  border: none !important;
}

.ananda-gradient-btn:hover {
  box-shadow: 0 6px 20px rgba(245, 158, 11, 0.6) !important;
  transform: translateY(-2px);
}

.google-btn {
  background-color: white !important;
  color: #757575 !important;
  border-color: #DADCE0 !important;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05) !important;
  transition: all 0.3s ease;
}

.google-btn:hover {
  background-color: #f8f9fa !important;
  box-shadow: 0 6px 15px rgba(0, 0, 0, 0.08) !important;
  transform: translateY(-2px);
}

.google-icon-wrapper {
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.google-icon {
  width: 18px;
  height: 18px;
}

.modern-input {
  border-radius: 12px;
  transition: all 0.3s ease;
}

.modern-input:focus-within {
  transform: translateY(-2px);
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
}
</style>
