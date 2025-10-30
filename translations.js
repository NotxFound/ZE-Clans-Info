let translations = {};
let currentLang = 'pl';

async function loadLanguage() {
    const response = await fetch('language.json');
    translations = await response.json();
}

document.addEventListener('DOMContentLoaded', async () => {
    await loadLanguage();

    document.querySelectorAll('.lang-button').forEach(button => {
        button.addEventListener('click', () => {
            const lang = button.getAttribute('data-lang');

            if (lang === 'pl') {
                location.reload();
            } else {
                translatePage(lang);
            }
        });
    });
});

function translatePage(language) {
    currentLang = language;

    document.querySelectorAll('[data-i18n]').forEach(elem => {
        const key = elem.getAttribute('data-i18n');
        if (translations[language] && translations[language][key]) {
            elem.textContent = translations[language][key];
        }
    });
    if (translations[language] && translations[language]['document.title']) {
        document.title = translations[language]['document.title'];
    }
}