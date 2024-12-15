import 'dart:convert';

String get scriptWrapper => '''
(function () {
    // Listening for the appearance of the body element to execute the script as soon as possible before the `interactive` event.
    const config = { attributes: false, childList: true, subtree: true };
    const callback = function (mutationsList, observer) {
        for (const mutation of mutationsList) {
            if (mutation.type === 'childList') {
                if (document.getElementsByTagName('body')[0]) {
                    console.log('body element has appeared');
                    // Execute the script when the body element appears.
                    script();
                    // Mission accomplished, no more to observe.
                    observer.disconnect();
                }
                break;
            }
        }
    };
    const observer = new MutationObserver(callback);
    observer.observe(document, config);

    const onReadystatechange = function () {
        if (document.readyState == 'interactive') {
            script();
        }
    }
    // The script is mainly executed by MutationObserver, and the following listeners are only used as fallbacks.
    const addListeners = function () {
        // here don't use document.onreadystatechange, which won't fire sometimes
        document.addEventListener('readystatechange', onReadystatechange);

        document.addEventListener('DOMContentLoaded', script, false);

        window.addEventListener('load', script);
    }
    const removeListeners = function () {
        document.removeEventListener('readystatechange', onReadystatechange);

        document.removeEventListener('DOMContentLoaded', script, false);

        window.removeEventListener('load', script);
    }
    const script = function () {
        {{CONTENT}}
        removeListeners();
    }
    if (document.readyState == 'interactive' || document.readyState == 'complete') {
        script();
    } else {
        addListeners();
    }
})();
''';

String getResourceLoadingBlockerScript(List<String> urlsToBlock) {
  final jsyfied = urlsToBlock.map((s) => "'$s'").join(", ");

  final content = '''
    const blockedUrls = [$jsyfied];
    function isBlocked(url) {
    return blockedUrls.some(blockedUrl => url.includes(blockedUrl));
  }

// Override XMLHttpRequest
const originalXHROpen = XMLHttpRequest.prototype.open;
XMLHttpRequest.prototype.open = function (method, url) {
    if (isBlocked(url)) {
        console.log('Blocked request: ' + url);
        throw new Error('Request blocked: ' + url); // Throw error instead of silent return
    }
    originalXHROpen.apply(this, arguments);
};
''';
  return scriptWrapper.replaceFirst('{{CONTENT}}', content);
}

// Generate the JavaScript code dynamically
String generateHidingScript(List<String> selectors) {
  // First, create a JavaScript array initialization with the selectors
  final jsSelectorsArray =
      jsonEncode(selectors); // This safely handles escaping

  return '''
// Initialize selectors as a global variable
window.adBlockerSelectors = $jsSelectorsArray;
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
    ''';
}
