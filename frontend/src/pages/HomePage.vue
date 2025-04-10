<template>
  <q-layout view="lHh Lpr lFf">
    <q-header elevated class="bg-dark">
      <q-toolbar>
        <q-toolbar-title class="text-white">Startsy</q-toolbar-title>
        <q-space />
        <q-btn outline color="white" label="Anmelden" :to="{ name: 'login' }" />
      </q-toolbar>
    </q-header>

    <q-page-container>
      <q-page class="hero-section text-white">
        <div class="hero-content q-pt-xl text-center">
          <h1 class="text-h2 text-weight-bold q-mb-sm gradient-text">Innovation beginnt mit Startsy</h1>
          <p class="text-subtitle1 text-grey-4 q-mb-xl">Wir verbinden Gründer mit Mitstreitern und ermöglichen die Realisierung erfolgreicher Startups</p>

          <div class="q-gutter-md">
            <q-btn label="Jetzt starten" color="primary" size="lg" class="q-px-xl pulse-btn" :to="{ name: 'register' }" />
            <q-btn label="Mehr erfahren" outline color="white" size="lg" class="q-px-xl hover-grow" @click="scrollToFeatures" />
          </div>
        </div>

        <div class="q-mb-lg text-center q-pt-xl">
          <q-icon name="keyboard_arrow_down" size="lg" class="animated-bounce" />
        </div>
      </q-page>

      <section id="features" class="q-py-xl bg-grey-2">
        <div class="container q-px-lg">
          <h2 class="text-h4 text-center q-mb-lg">Was wir bieten</h2>
          <div class="row q-col-gutter-lg">
            <div class="col-md-4" v-for="(feature, index) in features" :key="index">
              <q-card class="text-center q-pa-md feature-card hover-zoom">
                <q-icon :name="feature.icon" color="primary" size="xl" class="q-mb-md" />
                <h3 class="text-h6">{{ feature.title }}</h3>
                <p>{{ feature.description }}</p>
              </q-card>
            </div>
          </div>
        </div>
      </section>

      <div class="row justify-center bg-grey-9 q-py-md">
        <div class="col-12 col-md-10 text-center text-caption text-grey-5">
          &copy; 2025 Startsy | Alle Rechte vorbehalten.
        </div>
      </div>
    </q-page-container>
  </q-layout>
</template>

<script>
import { defineComponent, ref, onMounted } from 'vue'

export default defineComponent({
  name: 'HomePage',
  setup() {
    const features = ref([
      { icon: 'group_add', title: 'Gründer & Mitstreiter', description: 'Verbindet euch mit anderen Gründer:innen und Mitstreiter:innen für eure Startup-Ideen.' },
      { icon: 'business_center', title: 'Startup-Vermarktung', description: 'Erstellt eure Startup-Projekte und stellt sie einer breiten Community vor.' },
      { icon: 'search', title: 'Startup-Entwicklung', description: 'Nutze die Expertise unserer Community für die Entwicklung eures Produkts.' }
    ])

    const animateCounters = () => {
      const counters = document.querySelectorAll('.counter')
      const speed = 200
      counters.forEach(counter => {
        const target = +counter.getAttribute('data-target')
        const count = +counter.innerText
        const increment = target / speed
        if (count < target) {
          counter.innerText = Math.ceil(count + increment)
          setTimeout(animateCounters, 1)
        } else {
          counter.innerText = target.toLocaleString()
        }
      })
    }

    const scrollToFeatures = () => {
      const element = document.getElementById('features')
      element?.scrollIntoView({ behavior: 'smooth' })
    }

    onMounted(() => {
      const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            animateCounters()
            observer.unobserve(entry.target)
          }
        })
      }, { threshold: 0.5 })
      
      const statsSection = document.querySelector('.stat-card')
      if (statsSection) observer.observe(statsSection)
    })

    return { features, scrollToFeatures }
  }
})
</script>

<style scoped>
.hero-section {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  justify-content: center;
  padding: 20px;
  position: relative;
  overflow: hidden;
  background: linear-gradient(135deg, #1a237e 0%, #283593 50%, #3949ab 100%);
  background-size: 200% 200%;
  animation: gradientShift 15s ease infinite;
}

@keyframes gradientShift {
  0% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
}

.gradient-text {
  background: linear-gradient(90deg, #ffffff, #42b983, #ffffff);
  background-size: 200% auto;
  color: transparent;
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  animation: shine 3s linear infinite;
}

@keyframes shine {
  to { background-position: 200% center; }
}

.hero-content {
  max-width: 800px;
  margin: 0 auto;
}

.pulse-btn {
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0% { transform: scale(1); }
  50% { transform: scale(1.05); }
  100% { transform: scale(1); }
}

.hover-grow:hover {
  transform: scale(1.05);
}

.feature-card {
  transition: all 0.3s ease;
  border-radius: 10px;
}

.hover-zoom:hover {
  transform: translateY(-5px);
  box-shadow: 0 10px 20px rgba(0,0,0,0.1);
}

.stat-card {
  background: rgba(255,255,255,0.1);
  border-radius: 10px;
  padding: 20px;
  transition: all 0.3s ease;
}

.stat-card:hover {
  transform: translateY(-5px);
  background: rgba(255,255,255,0.2);
  box-shadow: 0 5px 15px rgba(0,0,0,0.2);
}

.about-card {
  border-radius: 10px;
  box-shadow: 0 5px 15px rgba(0,0,0,0.1);
}

.animated-bounce {
  animation: bounce 2s infinite;
}

@keyframes bounce {
  0%,20%,50%,80%,100% { transform: translateY(0); }
  40% { transform: translateY(-20px); }
  60% { transform: translateY(-10px); }
}

@media (max-width: 600px) {
  .stat-card { padding: 15px; }
  .hero-content h1 { font-size: 2rem; }
  .hero-content p { font-size: 1rem; }
}
</style>