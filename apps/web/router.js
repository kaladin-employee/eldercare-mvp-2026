// router.js: hash-based routing
export function navigateToPage(page) {
    history.pushState(null, '', `#${page}`);
}

window.addEventListener('popstate', (event) => {
    const path = window.location.hash.slice(1);
    if (!path) return;
    renderPage(path);
});

function renderPage(page) {
    switch (page) {
        case 'dashboard':
            import('./pages/dashboard.js').then(module => module.default());
            break;
        case 'elder':
            import('./pages/elder.js').then(module => module.default());
            break;
        case 'checkin':
            import('./pages/checkin.js').then(module => module.default());
            break;
        case 'settings':
            import('./pages/settings.js').then(module => module.default());
            break;
        default:
            console.log('Unknown page:', page);
    }
}