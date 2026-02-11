import { createRouter, createWebHistory, } from 'vue-router'
import { isConfigured, supabase } from './lib/supabase'
import NProgress from 'nprogress'
import 'nprogress/nprogress.css'

// Configure NProgress
NProgress.configure({ showSpinner: false, trickleSpeed: 200 })

const routes = [
    {
        path: '/',
        name: 'login',
        component: () => import('./components/Auth.vue')
    },
    {
        path: '/signup',
        name: 'signup',
        component: () => import('./components/Auth.vue')
    },
    {
        path: '/features',
        name: 'features',
        component: () => import('./views/Features.vue')
    },
    {
        path: '/pricing',
        name: 'pricing',
        component: () => import('./views/Pricing.vue')
    },
    {
        path: '/docs',
        name: 'docs',
        component: () => import('./views/Docs.vue')
    },
    {
        path: '/profile',
        name: 'profile',
        component: () => import('./components/Profile.vue')
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

router.beforeEach(async (to, from, next) => {
    NProgress.start()

    // 1. If not configured, stay on home or whatever (App.vue handles the global ConfigError overlay)
    if (!isConfigured) {
        return next()
    }

    const { data: { session } } = await supabase.auth.getSession()

    // 2. Define protected and public routes
    const publicRoutes = ['/', '/signup', '/features', '/pricing', '/docs']
    const isProtectedRoute = !publicRoutes.includes(to.path)

    if (session && (to.path === '/' || to.path === '/signup')) {
        next('/profile')
    } else if (!session && isProtectedRoute) {
        next('/')
    } else {
        next()
    }
})

router.afterEach(() => {
    NProgress.done()
})

export default router
