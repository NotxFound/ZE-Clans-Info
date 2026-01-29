function googleTranslateElementInit() {
    new google.translate.TranslateElement(
        { pageLanguage: 'pl', includedLanguages: 'en,ar,tr', layout: google.translate.TranslateElement.InlineLayout.SIMPLE },
        'google_translate_element'
    );
}