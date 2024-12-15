(function () {
    // Function to hide matching elements
    function hideElements() {
        const cssSelectors = window.adBlockerSelectors;
        const BATCH_SIZE = 1000;

        console.log('Initializing element hiding script with ' + cssSelectors.length + ' selectors');

        if (!Array.isArray(cssSelectors) || !cssSelectors.length) {
            console.warn('No valid selectors array found');
            return;
        }

        try {
            const batchCount = Math.ceil(cssSelectors.length / BATCH_SIZE);

            for (let i = 0; i < batchCount; i++) {
                const start = i * BATCH_SIZE;
                const end = Math.min(start + BATCH_SIZE, cssSelectors.length);
                const selectors = cssSelectors.slice(start, end);

                if (!Array.isArray(selectors) || !selectors.length) {
                    console.warn('Invalid selectors batch');
                    continue;
                }

                try {
                    // Ensure all items in selectors are strings
                    const validSelectors = selectors.filter(selector =>
                        typeof selector === 'string' && selector.trim().length > 0
                    );

                    if (!validSelectors.length) {
                        console.warn('No valid selectors in batch');
                        continue;
                    }

                    const selector = validSelectors.join(', ');
                    const elements = document.querySelectorAll(selector);
                    elements.forEach(el => {
                        try {
                            el.remove();
                        } catch (elementError) {
                            console.warn('Failed to remove element:', elementError);
                        }
                    });
                } catch (selectorError) {
                    console.warn('Invalid selector in batch:', selectorError);
                    continue;
                }
            }
            console.log('Processed batch ' + batchCount);
        } catch (error) {
            console.error('Error in hideElements:', error);
        }
    }

    // Observe DOM changes to handle dynamically added elements
    const observer = new MutationObserver((mutations) => {
        if (mutations.some(mutation => mutation.addedNodes.length > 0)) {
            hideElements();
        }
    });

    // Start observing the DOM with error handling
    try {
        observer.observe(document.body, {
            childList: true,
            subtree: true
        });
        console.log('MutationObserver successfully initialized');
    } catch (error) {
        console.error('Failed to initialize MutationObserver:', error);
    }

    // Initial hide on page load
    hideElements();

    console.log('Element hiding script initialized successfully');
})();