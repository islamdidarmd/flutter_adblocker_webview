import 'dart:convert';

String generateHidingScript(List<String> selectors) {
  final jsSelectorsArray = jsonEncode(selectors);
  return '''
    window.adBlockerSelectors = $jsSelectorsArray;
(function () {
    const selectors = window.adBlockerSelectors || [];
    const BATCH_SIZE = 1000;

    async function hideElements() {
        if (!Array.isArray(selectors) || !selectors.length) {
            console.log('[AdBlocker] No selectors to process');
            return;
        }

        try {
            const batchCount = Math.ceil(selectors.length / BATCH_SIZE);
            for (let i = 0; i < batchCount; i++) {
                const start = i * BATCH_SIZE;
                const end = Math.min(start + BATCH_SIZE, selectors.length);
                const batchSelectors = selectors.slice(start, end);

                document.querySelectorAll(batchSelectors.join(',')).forEach((el) => {
                    console.log('Removing element: ', el.id);
                    return el.remove();
                });
                await new Promise(resolve => setTimeout(resolve, 300));
            }
            console.info('[AdBlocker] Elements hide rules applied: ', selectors.length);
        } catch (error) {
            console.error('[AdBlocker] Error:', error);
        }
    }

    // Create a MutationObserver instance
    const observer = new MutationObserver(() => hideElements());

    // Start observing
    try {
        observer.observe(document.body, {
            childList: true,
            subtree: true
        });
        hideElements();
    } catch (error) {
        console.error('[AdBlocker] Observer error:', error);
    }
})();
  ''';
}
