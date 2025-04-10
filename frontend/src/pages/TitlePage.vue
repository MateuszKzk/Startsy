<template>
  <q-layout view="lHh Lpr lFf">
    <q-header elevated class="bg-dark">
      <q-toolbar>
        <q-toolbar-title class="text-white">Startsy</q-toolbar-title>
        <q-space />
        <q-btn flat label="Home" to="/" />
        <q-btn flat label="Über uns" to="/about" />
        <q-btn flat label="Dienstleistungen" to="/services" />
        <q-btn flat label="Kontakt" to="/contact" />
        <q-btn outline color="white" label="Anmelden" :to="{ name: 'login' }" />
      </q-toolbar>
    </q-header>

    <q-page-container>
      <!-- Hero Section - entfernt fullscreen Klasse -->
      <q-page class="hero-section bg-gradient text-white">
        <div class="hero-content q-pt-xl text-center">
          <h1 class="text-h2 text-weight-bold q-mb-sm">Innovation beginnt mit Startsy</h1>
          <p class="text-subtitle1 text-grey-4 q-mb-xl">Wir transformieren Ideen in digitale Lösungen</p>
          
          <div class="q-gutter-md">
            <q-btn 
              label="Jetzt starten" 
              color="primary" 
              size="lg" 
              class="q-px-xl"
              :to="{ name: 'register' }"
            />
            
            <q-btn 
              label="Mehr erfahren" 
              outline 
              color="white" 
              size="lg"
              class="q-px-xl"
              @click="scrollToFeatures"
            />
          </div>
        </div>
        
        <div class="q-mb-lg text-center q-pt-xl">
          <q-icon name="keyboard_arrow_down" size="lg" class="animated-bounce" />
        </div>
      </q-page>

      <!-- Features Section -->
      <section id="features" class="q-py-xl bg-grey-2">
        <div class="container q-px-lg">
          <h2 class="text-h4 text-center q-mb-lg">Was wir bieten</h2>
          
          <div class="row q-col-gutter-lg">
            <div class="col-md-4">
              <q-card class="text-center q-pa-md feature-card">
                <q-icon name="code" color="primary" size="xl" class="q-mb-md" />
                <h3 class="text-h6">Webentwicklung</h3>
                <p>Maßgeschneiderte Webanwendungen mit modernsten Technologien.</p>
              </q-card>
            </div>
            
            <div class="col-md-4">
              <q-card class="text-center q-pa-md feature-card">
                <q-icon name="phone_iphone" color="primary" size="xl" class="q-mb-md" />
                <h3 class="text-h6">Mobile Apps</h3>
                <p>Intuitive mobile Lösungen für iOS und Android.</p>
              </q-card>
            </div>
            
            <div class="col-md-4">
              <q-card class="text-center q-pa-md feature-card">
                <q-icon name="cloud" color="primary" size="xl" class="q-mb-md" />
                <h3 class="text-h6">Cloud Lösungen</h3>
                <p>Skalierbare Infrastruktur für Ihr Business.</p>
              </q-card>
            </div>
          </div>
        </div>
      </section>

      <!-- About Section -->
      <section class="q-py-xl bg-white">
        <div class="container q-px-lg">
          <div class="row items-center q-col-gutter-lg">
            <div class="col-md-6">
              <h2 class="text-h4 q-mb-md">Über Startsy</h2>
              <p class="q-mb-md">Seit 2018 helfen wir Unternehmen, ihre digitalen Ziele zu erreichen. Unser Team aus erfahrenen Entwicklern und Designern arbeitet eng mit Ihnen zusammen, um maßgeschneiderte Lösungen zu entwickeln.</p>
              <q-btn label="Unser Team kennenlernen" color="primary" outline to="/about" />
            </div>
            <div class="col-md-6">
              <q-img 
                src="https://images.unsplash.com/photo-1522071820081-009f0129c71c?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80" 
                class="rounded-borders shadow-5"
                ratio="16/9"
              />
            </div>
          </div>
        </div>
      </section>

      <!-- Portfolio Section -->
      <section class="q-py-xl bg-grey-2">
        <div class="container q-px-lg">
          <h2 class="text-h4 text-center q-mb-lg">Unsere Projekte</h2>
          
          <div class="row q-col-gutter-lg">
            <div class="col-md-4" v-for="(project, index) in projects" :key="index">
              <q-card class="portfolio-card">
                <q-img :src="project.image" :ratio="16/9" />
                <q-card-section>
                  <h3 class="text-h6">{{ project.title }}</h3>
                  <p>{{ project.description }}</p>
                </q-card-section>
              </q-card>
            </div>
          </div>
          
          <div class="text-center q-mt-lg">
            <q-btn label="Alle Projekte anzeigen" color="primary" to="/portfolio" />
          </div>
        </div>
      </section>

      <!-- Testimonials -->
      <section class="q-py-xl bg-white">
        <div class="container q-px-lg">
          <h2 class="text-h4 text-center q-mb-lg">Was unsere Kunden sagen</h2>
          
          <div class="row q-col-gutter-lg">
            <div class="col-md-4" v-for="(testimonial, index) in testimonials" :key="index">
              <q-card class="q-pa-md testimonial-card">
                <q-rating v-model="testimonial.rating" size="2em" color="amber" readonly class="q-mb-sm" />
                <p class="text-italic q-mb-sm">"{{ testimonial.text }}"</p>
                <div class="text-subtitle2">{{ testimonial.author }}</div>
                <div class="text-caption text-grey">{{ testimonial.position }}</div>
              </q-card>
            </div>
          </div>
        </div>
      </section>

      <!-- CTA Section -->
      <section class="q-py-xl bg-primary text-white text-center">
        <div class="container q-px-lg">
          <h2 class="text-h4 q-mb-md">Bereit für den nächsten Schritt?</h2>
          <p class="q-mb-lg">Kontaktieren Sie uns noch heute für eine kostenlose Beratung.</p>
          <q-btn label="Kontakt aufnehmen" color="white" text-color="primary" size="lg" to="/contact" />
        </div>
      </section>
    </q-page-container>

    <footer class="page-footer bg-dark text-white">
          <div class="container q-py-lg">
            <div class="row q-col-gutter-lg">
              <div class="col-md-4">
                <h3 class="text-h6 q-mb-md">Startsy</h3>
                <p>Die Zukunft beginnt hier. Wir helfen Ihnen, sie zu gestalten.</p>
                <div class="q-mt-md">
                  <q-btn round dense flat icon="facebook" />
                  <q-btn round dense flat icon="twitter" />
                  <q-btn round dense flat icon="linkedin" />
                  <q-btn round dense flat icon="instagram" />
                </div>
              </div>
              <div class="col-md-2">
                <h4 class="text-h6 q-mb-md">Links</h4>
                <q-list dense>
                  <q-item clickable to="/">
                    <q-item-section>Home</q-item-section>
                  </q-item>
                  <q-item clickable to="/about">
                    <q-item-section>Über uns</q-item-section>
                  </q-item>
                  <q-item clickable to="/services">
                    <q-item-section>Dienstleistungen</q-item-section>
                  </q-item>
                  <q-item clickable to="/contact">
                    <q-item-section>Kontakt</q-item-section>
                  </q-item>
                </q-list>
              </div>
              <div class="col-md-3">
                <h4 class="text-h6 q-mb-md">Kontakt</h4>
                <p>Musterstraße 123<br>10115 Berlin<br>Deutschland</p>
                <p>info@startsy.de<br>+49 30 12345678</p>
              </div>
              <div class="col-md-3">
                <h4 class="text-h6 q-mb-md">Newsletter</h4>
                <q-input outlined v-model="email" label="Ihre E-Mail" dark class="q-mb-sm" />
                <q-btn label="Abonnieren" color="primary" />
              </div>
            </div>
          </div>
          <div class="text-center q-py-sm bg-grey-9">
            &copy; 2023 Startsy GmbH. Alle Rechte vorbehalten.
          </div>
        </footer>
  </q-layout>
</template>

<script>
import { defineComponent, ref } from 'vue'

export default defineComponent({
  name: 'HomePage',
  setup() {
    const email = ref('')
    const projects = ref([
      {
        title: 'E-Commerce Plattform',
        description: 'Eine maßgeschneiderte Online-Shopping-Lösung mit KI-Empfehlungen.',
        image: 'https://images.unsplash.com/photo-1556740738-b6a63e27c4df?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80'
      },
      {
        title: 'Fitness App',
        description: 'Mobile Anwendung mit personalisierten Trainingsplänen.',
        image: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80'
      },
      {
        title: 'Unternehmensdashboard',
        description: 'Echtzeit-Datenvisualisierung für Geschäftsanalysen.',
        image: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80'
      }
    ])

    const testimonials = ref([
      {
        text: "Startsy hat unsere digitale Präsenz komplett transformiert. Die Ergebnisse sprechen für sich!",
        author: "Max Mustermann",
        position: "CEO, Muster GmbH",
        rating: 5
      },
      {
        text: "Ausgezeichnete Zusammenarbeit. Das Team ist professionell und liefert pünktlich.",
        author: "Erika Musterfrau",
        position: "CTO, Beispiel AG",
        rating: 4
      },
      {
        text: "Die App, die Startsy für uns entwickelt hat, wurde von unseren Kunden geliebt.",
        author: "Thomas Test",
        position: "Marketing Director, Test & Co",
        rating: 5
      }
    ])

    const scrollToFeatures = () => {
      const element = document.getElementById('features')
      element?.scrollIntoView({ behavior: 'smooth' })
    }

    return {
      email,
      projects,
      testimonials,
      scrollToFeatures
    }
  }
})
</script>

<style scoped>
/* Ersetzt die fullscreen Klasse */
.hero-section {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  justify-content: center;
  padding: 20px;
}

.hero-content {
  max-width: 800px;
  margin: 0 auto;
}

/* Rest des CSS bleibt gleich */
.bg-gradient {
  background: linear-gradient(135deg, #1a237e 0%, #283593 50%, #3949ab 100%);
}

@keyframes bounce {
  0%, 20%, 50%, 80%, 100% {
    transform: translateY(0);
  }
  40% {
    transform: translateY(-20px);
  }
  60% {
    transform: translateY(-10px);
  }
}

.animated-bounce {
  animation: bounce 2s infinite;
}
</style>