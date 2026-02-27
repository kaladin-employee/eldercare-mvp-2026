// App main logic
import { setupRouting, saveCheckin } from './routing.js';

window.onload = () => {
  const appDiv = document.getElementById('app');
  if (appDiv) {
    setupRouting(appDiv);
    // Simulate a check-in for demo
    setTimeout(() => saveCheckin(), 2000);
  }
}