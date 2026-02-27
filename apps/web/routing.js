// Routing logic
export function setupRouting(appDiv) {
  const routes = [
    { path: '/dashboard', component: Dashboard },
    { path: '/elder/:id', component: Elder },
    { path: '/checkin', component: Checkin },
    { path: '/settings', component: Settings }
  ];

  const routeHistory = [];
  let currentPath = '';

  function handleHashchange() {
    const hash = window.location.hash.replace('#/', '');
    if (hash !== currentPath) {
      currentPath = hash;
      loadComponent(appDiv, routes.find(route => route.path === currentPath));
    }
  }
  window.addEventListener('hashchange', handleHashchange);

  function loadComponent(div, componentDef) {
    if (componentDef) {
      const componentElement = document.createElement('div');
      div.appendChild(componentElement);
      componentDef.component();
    } else {
      console.error('Unknown route:', currentPath);
    }
  }
}

// Dummy components for demonstration
function Dashboard() {}
function Elder(id) {}
function Checkin() {}
function Settings() {}