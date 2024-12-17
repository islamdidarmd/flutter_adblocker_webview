(function () {
    const blockedUrls = ['dc.bubbiesxylaria.top', 'embasic.pro'];
    
    function isBlocked(url) {
        return blockedUrls.some(blockedUrl => url.includes(blockedUrl));
    }

    // Override XMLHttpRequest
    const originalXHROpen = XMLHttpRequest.prototype.open;
    XMLHttpRequest.prototype.open = function (method, url) {
        if (isBlocked(url)) {
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
        
        if (isBlocked(url)) {
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
                    return;
                }
                return originalSetAttribute.call(this, name, value);
            };
        }
        
        return element;
    };
})();
