import { createRouter, createWebHistory, } from 'vue-router'
import { isConfigured, supabase } from './lib/supabase'
import NProgress from 'nprogress'
import 'nprogress/nprogress.css'

// Configure NProgress
NProgress.configure({ showSpinner: false, trickleSpeed: 200 })

const routes = [
    // Public Routes
    {
        path: '/',
        name: 'home',
        component: () => import('./views/Home.vue')
    },
    {
        path: '/login',
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

    // Dashboard (Protected) Routes
    {
        path: '/dashboard',
        component: () => import('./components/DashboardLayout.vue'),
        children: [
            {
                path: '/profile',
                name: 'profile',
                component: () => import('./components/Profile.vue')
            },
            {
                path: '/moderate',
                name: 'moderate',
                component: () => import('./components/ImageModerator.vue')
            },
            {
                path: '/history',
                name: 'history',
                component: () => import('./components/ModerationHistory.vue'),
                props: { isAdminView: false }
            },
            {
                path: '/admin/history',
                name: 'admin-history',
                component: () => import('./components/ModerationHistory.vue'),
                props: { isAdminView: true }
            },
            {
                path: '/api-keys',
                name: 'api-keys',
                component: () => import('./components/ApiKeyManager.vue'),
                props: { isAdminView: false }
            },
            {
                path: '/admin/api-keys',
                name: 'admin-api-keys',
                component: () => import('./components/ApiKeyManager.vue'),
                props: { isAdminView: true }
            },
            {
                path: '/admin/users',
                name: 'admin-users',
                component: () => import('./components/AdminUsers.vue')
            }
        ]
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

    if (!isConfigured) {
        return next()
    }

    const { data: { session } } = await supabase.auth.getSession()

    const publicRoutes = ['/', '/login', '/signup', '/features', '/pricing', '/docs']
    const isProtectedRoute = !publicRoutes.includes(to.path)

    if (session && (to.path === '/login' || to.path === '/signup')) {
        next('/profile')
    } else if (!session && isProtectedRoute) {
        next('/login')
    } else {
        next()
    }
})

import { appName } from './lib/supabase'

router.afterEach((to) => {
    NProgress.done()
    const pageName = to.name ? to.name.charAt(0).toUpperCase() + to.name.slice(1) : ''
    document.title = pageName ? `${pageName} | ${appName}` : appName
})

export default router
