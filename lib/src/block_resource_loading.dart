import 'package:adblocker_manager/adblocker_manager.dart';

String getResourceLoadingBlockerScript(List<ResourceRule> rules) {
  // Convert ResourceRules to JavaScript objects
  final jsRules = rules.map((rule) => '''
    {
      url: '${rule.url}',
      isException: ${rule.isException}
    }
  ''').join(',\n');

  final content = '''
    window.adBlockerRules = [$jsRules];
    
    function setupResourceBlocking() {
        const rules = window.adBlockerRules || [];
    
    function domainMatches(rule, target) {
        return rule === target || target.includes(rule);
    }
    
    function isBlocked(url, originType) {
        // First check exception rules
        const isException = rules.some(rule => {
            return rule.isException && domainMatches(rule.url, url);
        });
        
        if (isException) {
            console.log(`[EXCEPTION][\${originType}] \${url}`, {
                domain: url,
                currentDomain: window.location.hostname
            });
            return false;
        }

        // Then check blocking rules
        const blockedRule = rules.find(rule => {
            return !rule.isException && domainMatches(rule.url, url);
        });

        if (blockedRule) {
            console.log(`[BLOCKED][\${originType}] \${url}`, {
                domain: url,
                rule: blockedRule.url,
                currentDomain: window.location.hostname
            });
            return true;
        }
        return false;
    }

    // Override XMLHttpRequest
    const originalXHROpen = XMLHttpRequest.prototype.open;
    XMLHttpRequest.prototype.open = function (method, url) {
        if (isBlocked(url, 'XHR')) {
            return new Proxy(new XMLHttpRequest(), {
                get: function(target, prop) {
                    if (prop === 'send') return function() {};
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
        if (isBlocked(url, 'Fetch')) {
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
                if (name === 'src' && isBlocked(value, 'Script')) {
                    return;
                }
                return originalSetAttribute.call(this, name, value);
            };
        }
        
        return element;
    };

    // Block image loading
    const originalImageSrc = Object.getOwnPropertyDescriptor(Image.prototype, 'src');
    Object.defineProperty(Image.prototype, 'src', {
        get: function() {
            return originalImageSrc.get.call(this);
        },
        set: function(value) {
            if (isBlocked(value, 'Image')) {
                return;
            }
            originalImageSrc.set.call(this, value);
        }
    });

    console.log('[AdBlocker] Resource blocking initialized with', rules.length, 'rules');
    }
  ''';

  return '''
    (function () {
        // Listening for the appearance of the body element to execute the script as early as possible
        const config = { attributes: false, childList: true, subtree: true };
        const callback = function (mutationsList, observer) {
            for (const mutation of mutationsList) {
                if (mutation.type === 'childList') {
                    if (document.getElementsByTagName('body')[0]) {
                        console.log('[AdBlocker] Body element detected, initializing blocking');
                        script();
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

        const addListeners = function () {
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
            try {
                $content
                setupResourceBlocking();
            } catch (error) {
                console.error('[AdBlocker] Setup error:', error);
            }
            removeListeners();
        }

        if (document.readyState == 'interactive' || document.readyState == 'complete') {
            script();
        } else {
            addListeners();
        }
    })();
  ''';
}
