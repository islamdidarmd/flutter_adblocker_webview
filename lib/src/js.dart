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
            // Silently fail by making a dummy XHR object that does nothing
            console.log('Blocked XHR:', url);
            return new Proxy(new XMLHttpRequest(), {
                get: function(target, prop) {
                    if (prop === 'send') {
                        return function() {};
                    }
                    return target[prop];
                }
            });
        }
        return originalXHROpen.apply(this, arguments);
    };

    // Override Fetch API
    const originalFetch = window.fetch;
    window.fetch = function (resource, init) {
        const url = resource instanceof Request ? resource.url : resource;
        console.log('Fetching:', url);
        if (isBlocked(url)) {
            console.log('Blocked fetch:', url);
            // Return empty response instead of rejecting
              return Promise.resolve(new Response('', {
                status: 200,
                statusText: 'OK'
            }));
        }
        
        return originalFetch.apply(this, arguments);
    };

    // Block dynamic script loading
    const originalCreateElement = document.createElement;
    document.createElement = function (tagName) {
        const element = originalCreateElement.apply(document, arguments);

        if (tagName.toLowerCase() === 'script') {
            const originalSetAttribute = element.setAttribute;
            element.setAttribute = function(name, value) {
                if (name === 'src' && isBlocked(value)) {
                    console.log('Blocked script:', value);
                    return;
                }
                return originalSetAttribute.call(this, name, value);
            };
        }
        
        return element;
    };

    console.log('Resource blocking script initialized');
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
console.log('Initializing element hiding script with ' + window.adBlockerSelectors.length + ' selectors');

(function () {
    // Function to hide matching elements
    function hideElements() {
        const cssSelectors = window.adBlockerSelectors;
        const BATCH_SIZE = 1000;

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
