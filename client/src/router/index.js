import { createRouter, createWebHistory } from 'vue-router'
import { supabase } from '../supabase'

const routes = [
  {
    path: '/',
    name: 'login',
    component: () => import('../views/Login.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/register',
    name: 'register',
    component: () => import('../views/Register.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/reset-password',
    name: 'resetPassword',
    component: () => import('../views/ResetPassword.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/dashboard',
    name: 'dashboard',
    component: () => import('../views/Dashboard.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/profile',
    name: 'profile',
    component: () => import('../views/Profile.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/admin/email-access',
    name: 'adminEmailAccess',
    component: () => import('../views/AdminEmailAccess.vue'),
    meta: { requiresAuth: true, requiresAdmin: true }
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/'
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// Fungsi untuk memeriksa apakah pengguna adalah admin
const isUserAdmin = async (user) => {
  if (!user) return false
  
  try {
    // Periksa apakah email pengguna adalah admin
    // Anda bisa menambahkan logika khusus di sini
    // Contoh: email tertentu yang dianggap sebagai admin
    const adminEmails = ['admin@anandagroup.com', 'superadmin@anandagroup.com']
    return adminEmails.includes(user.email)
  } catch (error) {
    console.error('Error checking admin status:', error)
    return false
  }
}

// Navigation guard untuk memeriksa autentikasi
router.beforeEach(async (to, from, next) => {
  const { data } = await supabase.auth.getSession()
  const currentUser = data?.session?.user

  const requiresAuth = to.matched.some(record => record.meta.requiresAuth)
  const requiresAdmin = to.matched.some(record => record.meta.requiresAdmin)

  if (requiresAuth && !currentUser) {
    next('/')
  } else if (requiresAdmin && !(await isUserAdmin(currentUser))) {
    // Jika halaman memerlukan hak admin tetapi pengguna bukan admin
    next('/dashboard')
  } else if (to.path === '/' && currentUser) {
    next('/dashboard')
  } else {
    next()
  }
})

export default router
