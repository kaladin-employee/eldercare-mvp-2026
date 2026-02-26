// app.js: boot and render the UI
import { render } from './renderer.js';
import { navigateToPage } from './router.js';
import { getLastCheckIn, getCheckIns } from './store.js';

window.onload = () => {
    const navLinks = document.querySelectorAll('nav ul li a');
    navLinks.forEach(link => {
        link.addEventListener('click', (event) => {
            event.preventDefault();
            navigateToPage(event.target.hash.slice(1));
        });
    });

    render(); // Initial rendering
}