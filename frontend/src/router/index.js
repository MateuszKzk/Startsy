import { route } from 'quasar/wrappers'
import { createRouter, createWebHistory } from 'vue-router'

import HomePage from 'src/pages/HomePage.vue'
import LoginPage from 'src/pages/LoginPage.vue'
import RegisterPage from 'src/pages/RegisterPage.vue'
import Dashboard from 'src/pages/DashboardPage.vue'
import AboutUsPage from 'src/pages/AboutUsPage.vue'
import StartUpsPage from 'src/pages/StartUpsPage.vue'

const routes = [
  {
    path: '/',
    name: 'home',
    component: HomePage
  },
  {
    path: '/dashboard',
    name: 'dashboard',
    component: Dashboard,
    meta: { requiresAuth: true }
  },
  {
    path: '/startups',
    name: 'startups',
    component: StartUpsPage,
    meta: { requiresAuth: true, title: 'Meine Startups' }
  },
  {
    path: '/about',
    name: 'about-us',
    component: AboutUsPage,
    meta: { title: 'Über Uns' }
  },
  {
    path: '/login',
    name: 'login',
    component: LoginPage,
    meta: { guestOnly: true }
  },
  {
    path: '/register',
    name: 'register',
    component: RegisterPage,
    meta: { guestOnly: true }
  },
    
  {
    path: '/settings',
    component: () => import('layouts/MainLayout.vue'),
    children: [
      {
        path: '',
        name: 'settings',
        component: () => import('pages/SettingsPage.vue'),
        meta: { requiresAuth: true, title: 'Einstellungen' }
      }
    ]
  }
  
  
  
  
  
]

export default route(function () {
  const router = createRouter({
    history: createWebHistory(),
    routes,
    scrollBehavior(to, from, savedPosition) {
      return savedPosition || { top: 0 }
    }
  })

  router.beforeEach((to, from, next) => {
    const isAuthenticated = !!localStorage.getItem('auth_token')
    const requiresAuth = to.matched.some(record => record.meta.requiresAuth)
    const guestOnly = to.matched.some(record => record.meta.guestOnly)

    document.title = to.meta.title ? `${to.meta.title} | Startsy` : 'Startsy'

    if (requiresAuth && !isAuthenticated) {
      return next({ name: 'login', query: { redirect: to.fullPath } })
    }

    if (guestOnly && isAuthenticated) {
      return next({ name: 'dashboard' })  // Weiterleitung für authentifizierte Benutzer zu 'home'
    }

    next()
  })

  return router
})
