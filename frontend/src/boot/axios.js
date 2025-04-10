import { boot } from 'quasar/wrappers'
import axios from 'axios'

const api = axios.create({
  baseURL: 'http://localhost:5000'
})

export default boot(({ app }) => {
    // Request Interceptor für JWT Token
    api.interceptors.request.use(config => {
      const token = localStorage.getItem('auth_token')
      if (token) {
        config.headers.Authorization = `Bearer ${token}`
      }
      return config
    })
    
    // This should be using api, not axios
    app.config.globalProperties.$axios = axios // <-- Change to api
    app.config.globalProperties.$api = api
  })

export { api }