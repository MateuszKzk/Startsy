import { route } from 'quasar/wrappers'
import { createRouter, createWebHistory } from 'vue-router'
import { api } from 'src/boot/axios'

const routes = [
  {
    path: '/',
    name: 'home',
    component: () => import('pages/HomePage.vue')
  },
  {
    path: '/dashboard',
    name: 'dashboard',
    component: () => import('pages/DashboardPage.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/startups',
    name: 'startups',
    component: () => import('pages/StartUpsPage.vue'),
    meta: { requiresAuth: true, title: 'Meine Startups' }
  },
  {
    path: '/profile',
    name: 'profile',
    component: () => import('pages/ProfilePage.vue'),
    meta: { requiresAuth: true, title: 'My Profile' }
  },
  {
    path: '/login',
    name: 'login',
    component: () => import('pages/LoginPage.vue'),
    meta: { guestOnly: true }
  },
  {
    path: '/register',
    name: 'register',
    component: () => import('pages/RegisterPage.vue'),
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
  },

  {
    path: '/chat',
    name: 'chat',
    component:() => import('pages/ChatPage.vue'),
    meta: {requiresAuth : true}
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

  router.beforeEach(async (to, from, next) => {
    const requiresAuth = to.matched.some(record => record.meta.requiresAuth);
    const guestOnly = to.matched.some(record => record.meta.guestOnly);
  
    try {
      const response = await api.get('/api/me');
      if (response.data?.user) {
        if (guestOnly) return next({ name: 'dashboard' });
        return next();
      }
    } catch (error) {
      if (requiresAuth) {
        return next({
          name: 'login',
          query: { redirect: to.fullPath !== '/' ? to.fullPath : undefined }
        });
      }
      console.error(error);
    }
    next();
  });

  return router
})