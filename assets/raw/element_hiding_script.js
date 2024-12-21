(function () {
    const selectors = window.adBlockerSelectors || [];
    const BATCH_SIZE = 1000;
    let hiddenElements = 0;

    function hideElements() {
        if (!Array.isArray(selectors) || !selectors.length) {
            console.warn('[AdBlocker] No valid selectors found');
            return;
        }

        try {
            const batchCount = Math.ceil(selectors.length / BATCH_SIZE);
            console.log(`[AdBlocker] Processing ${selectors.length} selectors in ${batchCount} batches`);

            for (let i = 0; i < batchCount; i++) {
                const start = i * BATCH_SIZE;
                const end = Math.min(start + BATCH_SIZE, selectors.length);
                const batchSelectors = selectors.slice(start, end);

                try {
                    // Create one combined selector for better performance
                    const combinedSelector = batchSelectors
                        .filter(selector => typeof selector === 'string' && selector.trim())
                        .join(', ');

                    if (!combinedSelector) {
                        console.warn(`[AdBlocker] Batch ${i + 1}: No valid selectors`);
                        continue;
                    }

                    // Query all elements at once
                    const elements = document.querySelectorAll(combinedSelector);
                    elements.forEach(el => {
                        try {
                            const selector = batchSelectors.find(s => el.matches(s));
                            console.log(`[AdBlocker] Hiding element:`, {
                                selector,
                                tagName: el.tagName,
                                id: el.id,
                                classes: Array.from(el.classList)
                            });
                            el.remove();
                            hiddenElements++;
                        } catch (elementError) {
                            console.warn('[AdBlocker] Failed to remove element:', elementError);
                        }
                    });

                    console.log(`[AdBlocker] Batch ${i + 1}/${batchCount}: Processed ${elements.length} elements`);
                } catch (batchError) {
                    console.warn(`[AdBlocker] Error in batch ${i + 1}:`, batchError);
                }
            }

            console.log(`[AdBlocker] Hiding completed: ${hiddenElements} elements hidden`);
        } catch (error) {
            console.error('[AdBlocker] Error in hideElements:', error);
        }
    }

    // Create a MutationObserver instance
    const observer = new MutationObserver((mutations) => {
        let shouldHide = false;
        for (const mutation of mutations) {
            if (mutation.addedNodes.length) {
                shouldHide = true;
                break;
            }
        }
        if (shouldHide) {
            console.log('[AdBlocker] DOM changed, re-running element hiding');
            hideElements();
        }
    });

    // Start observing with error handling
    try {
        observer.observe(document.body, {
            childList: true,
            subtree: true
        });
        console.log('[AdBlocker] MutationObserver initialized');
    } catch (error) {
        console.error('[AdBlocker] Failed to initialize MutationObserver:', error);
    }

    // Initial hide
    hideElements();
})();