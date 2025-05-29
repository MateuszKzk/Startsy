// src/boot/pinia.js (create this file if it doesn't exist)
import { createPinia } from 'pinia'

export default ({ app }) => {
  const pinia = createPinia()
  app.use(pinia)
}