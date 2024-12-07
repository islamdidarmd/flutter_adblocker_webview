const blockedUrls = ['ads', 'tracking', 'doubleclick.net', 'googlesyndication.com'];

// Override XMLHttpRequest
const originalXHROpen = XMLHttpRequest.prototype.open;
XMLHttpRequest.prototype.open = function (method, url) {
    if (blockedUrls.some(blocked => url.includes(blocked))) {
        console.log('Blocked request: ' + url);
        return; // Block the request
    }
    originalXHROpen.apply(this, arguments);
};

// Override fetch
const originalFetch = window.fetch;
window.fetch = function (input, init) {
    const url = typeof input === 'string' ? input : input.url;
    if (blockedUrls.some(blocked => url.includes(blocked))) {
        console.log('Blocked fetch request: ' + url);
        return Promise.reject(new Error('Blocked request: ' + url));
    }
    return originalFetch(input, init);
};
