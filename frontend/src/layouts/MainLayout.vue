<!-- layouts/MainLayout.vue -->
<template>
  <q-layout view="lHh Lpr lFf">
    <q-header elevated>
      <q-toolbar>
        <q-toolbar-title>My App</q-toolbar-title>
      </q-toolbar>
    </q-header>

    <q-page-container>
      <router-view /> <!-- Hier kommt dein q-page rein -->
    </q-page-container>
  </q-layout>
</template>
