import 'dart:convert';

import 'package:adblocker_core/adblocker_core.dart';

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

String getResourceLoadingBlockerScript(List<BlockRule> rules) {
  // Convert BlockRules to JavaScript objects
  final jsRules = rules
      .map((rule) => '''
    {
      filter: '${rule.filter}',
      resourceType: '${rule.resourceType.name}',
      isThirdParty: ${rule.isThirdParty},
      ${rule.domains == null ? '' : '''
      domains: {
        include: [${rule.domains!.includeDomains.map((d) => "'$d'").join(', ')}],
        exclude: [${rule.domains!.excludeDomains.map((d) => "'$d'").join(', ')}]
      },
      '''}
    }
  ''')
      .join(',\n');

  final content = '''
    window.adBlockerRules = [$jsRules];
    
    const rules = window.adBlockerRules || [];
    
    function isBlocked(url, type, isThirdParty) {
        const blockedRule = rules.find(rule => {
            if (!url.includes(rule.filter)) return false;
            if (rule.resourceType !== 'any' && rule.resourceType !== type) return false;
            if (rule.isThirdParty && !isThirdParty) return false;
            
            if (rule.domains) {
                const currentDomain = window.location.hostname;
                if (rule.domains.exclude.some(d => currentDomain.endsWith(d))) return false;
                if (rule.domains.include.length && !rule.domains.include.some(d => currentDomain.endsWith(d))) return false;
            }
            return true;
        });

        if (blockedRule) {
            console.log(`[BLOCKED \${type}] \${url}`, {
                rule: blockedRule.filter,
                type: blockedRule.resourceType,
                isThirdParty,
                currentDomain: window.location.hostname
            });
            return true;
        }
        return false;
    }

    // Rest of the blocking script...
    ${_getBlockingScript()}

    console.log('[AdBlocker] Initialized with', rules.length, 'rules');
  ''';

  return scriptWrapper.replaceFirst('{{CONTENT}}', content);
}

String _getBlockingScript() => '''
    const originalXHROpen = XMLHttpRequest.prototype.open;
    XMLHttpRequest.prototype.open = function (method, url) {
        const isThirdParty = new URL(url, window.location.href).hostname !== window.location.hostname;
        
        if (isBlocked(url, 'xhr', isThirdParty)) {
            return new Proxy(new XMLHttpRequest(), {
                get: function(target, prop) {
                    if (prop === 'send') return function() {};
                    return target[prop];
                }
            });
        }
        return originalXHROpen.apply(this, arguments);
    };

    const originalFetch = window.fetch;
    window.fetch = function (resource, init) {
        const url = resource instanceof Request ? resource.url : resource;
        const isThirdParty = new URL(url, window.location.href).hostname !== window.location.hostname;
        
        if (isBlocked(url, 'xhr', isThirdParty)) {
            return Promise.resolve(new Response('', {
                status: 200,
                statusText: 'OK'
            }));
        }
        
        return originalFetch.apply(this, arguments);
    };

    const originalCreateElement = document.createElement;
    document.createElement = function (tagName) {
        const element = originalCreateElement.apply(document, arguments);
        
        if (tagName.toLowerCase() === 'script') {
            const originalSetAttribute = element.setAttribute;
            element.setAttribute = function(name, value) {
                if (name === 'src') {
                    const isThirdParty = new URL(value, window.location.href).hostname !== window.location.hostname;
                    if (isBlocked(value, 'script', isThirdParty)) {
                        return;
                    }
                }
                return originalSetAttribute.call(this, name, value);
            };
        }
        
        return element;
    };
''';

