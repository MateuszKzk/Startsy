import { route } from 'quasar/wrappers';
import { createRouter, createWebHistory } from 'vue-router';
import LoginPage from 'src/pages/LoginPage.vue';
import RegisterPage from 'src/pages/RegisterPage.vue';
import HomePage from 'src/pages/HomePage.vue';
import MainLayout from 'src/layouts/MainLayout.vue';

const routes = [
  {
    path: '/',
    component: MainLayout,
    children: [
      { path: '', redirect: '/home' }, // Standard-Redirect
      { path: 'login', name: 'login', component: LoginPage },
      { path: 'register', name: 'register', component: RegisterPage },
      { 
        path: 'home', 
        name: 'home', 
        component: HomePage,
        meta: { requiresAuth: true } // Geschützte Route
      }
    ]
  }
];

export default route(function (/* { store, ssrContext } */) {
  const router = createRouter({
    history: createWebHistory(),
    routes
  });

  // Navigation Guard für Authentifizierung
  router.beforeEach((to, from, next) => {
    const isAuthenticated = localStorage.getItem('auth_token');
    
    if (to.matched.some(record => record.meta.requiresAuth) && !isAuthenticated) {
      next({ name: 'login' });
    } else if ((to.name === 'login' || to.name === 'register') && isAuthenticated) {
      next({ name: 'home' }); // Bereits eingeloggte User umleiten
    } else {
      next();
    }
  });

  return router;
});