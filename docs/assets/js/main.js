// Language switching functionality

// Get saved language or detect from browser
function getInitialLang() {
    const saved = localStorage.getItem('tasklane-lang');
    if (saved) return saved;

    const browserLang = navigator.language.toLowerCase();
    if (browserLang.startsWith('fr')) return 'fr';
    return 'en';
}

// Set language
function setLang(lang) {
    localStorage.setItem('tasklane-lang', lang);

    // Update buttons
    document.getElementById('btn-en').classList.toggle('active', lang === 'en');
    document.getElementById('btn-fr').classList.toggle('active', lang === 'fr');

    // Update all translatable elements
    document.querySelectorAll('[data-en]').forEach(el => {
        const text = el.getAttribute(`data-${lang}`);
        if (text) {
            el.textContent = text;
        }
    });

    // Update HTML lang attribute
    document.documentElement.lang = lang;
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', () => {
    const lang = getInitialLang();
    setLang(lang);
});

// Smooth scroll for anchor links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({ behavior: 'smooth' });
        }
    });
});
