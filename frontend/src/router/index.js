import { route } from 'quasar/wrappers'
import { createRouter, createWebHistory } from 'vue-router'

import TitlePage from 'src/pages/TitlePage.vue'
import LoginPage from 'src/pages/LoginPage.vue'
import RegisterPage from 'src/pages/RegisterPage.vue'
import HomePage from 'src/pages/HomePage.vue'
import AboutUsPage from 'src/pages/AboutUsPage.vue'
import StartUpsPage from 'src/pages/StartUpsPage.vue'
import SettingsPage from 'src/pages/SettingsPage.vue'

const routes = [
  {
    path: '/',
    name: 'title',
    component: TitlePage
  },
  {
    path: '/home',
    name: 'home',
    component: HomePage,
    meta: { requiresAuth: true }
  },
  {
    path: '/startups',
    name: 'startups',
    component: StartUpsPage,
    meta: { requiresAuth: true, title: 'Meine Startups' }
  },
  {
    path: '/settings',
    name: 'settings',
    component: SettingsPage,
    meta: { requiresAuth: true, title: 'Einstellungen' }
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

    // Setze den Seitentitel
    document.title = to.meta.title ? `${to.meta.title} | Startsy` : 'Startsy'

    // Auth-Prüfung
    if (requiresAuth && !isAuthenticated) {
      return next({ name: 'login', query: { redirect: to.fullPath } })
    }

    if (guestOnly && isAuthenticated) {
      return next({ name: 'home' })  // Weiterleitung für authentifizierte Benutzer zu 'home'
    }

    next()
  })

  return router
})
