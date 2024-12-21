(function () {
    const rules = window.adBlockerRules || [];
    
    function isBlocked(url, type, isThirdParty) {
        const blockedRule = rules.find(rule => {
            // Check if URL matches the filter pattern
            if (!url.includes(rule.filter)) return false;
            
            // Check resource type
            if (rule.resourceType !== 'any' && rule.resourceType !== type) return false;
            
            // Check third-party status if specified
            if (rule.isThirdParty && !isThirdParty) return false;
            
            // Check domain restrictions if any
            if (rule.domains) {
                const currentDomain = window.location.hostname;
                if (rule.domains.exclude.some(d => currentDomain.endsWith(d))) return false;
                if (rule.domains.include.length && !rule.domains.include.some(d => currentDomain.endsWith(d))) return false;
            }
            
            return true;
        });

        if (blockedRule) {
            console.log(`[BLOCKED ${type}] ${url}`, {
                rule: blockedRule.filter,
                type: blockedRule.resourceType,
                isThirdParty,
                currentDomain: window.location.hostname
            });
            return true;
        }
        return false;
    }

    // Override XMLHttpRequest
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

    // Override Fetch API
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

    // Block dynamic script loading
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

    console.log('[AdBlocker] Initialized with', rules.length, 'rules');
})();
