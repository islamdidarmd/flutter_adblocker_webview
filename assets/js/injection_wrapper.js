(function () {
    // Listening for the appearance of the body element to execute the script as soon as possible before the `interactive` event.
    const config = { attributes: false, childList: true, subtree: true };
    const callback = function (mutationsList, observer) {
        for (const mutation of mutationsList) {
            if (mutation.type === 'childList') {
                if (document.getElementsByTagName('body')[0]) {
                    {{DEBUG}} console.log('body element has appeared');
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
        {{INJECTION}}
        removeListeners();
    }
    if (document.readyState == 'interactive' || document.readyState == 'complete') {
        script();
    } else {
        addListeners();
    }
})(),
function onStyleSheetReceived(styleSheet) {
    if (styleSheet.length) {
      { { DEBUG } } console.log('stylesheet length: ' + styleSheet.length);
      var html = document.getElementsByTagName('html')[0];
      var style = document.createElement('style');
      html.appendChild(style);
      style.textContent = styleSheet;
      { { DEBUG } } console.log('finished injecting stylesheet');
    } else {
      { { DEBUG } } console.log('stylesheet is empty, skipped');
    }
    // hide by ExtendedCss
    try {
      GetExtendedCssStyleSheet.postMessage(document.location.href);
    } catch (err) {
      { { DEBUG } } console.log(`ExtendedCss rules failed '${css}' for ${document.location.href} by ${err}`);
      throw err;
    }
  },
  function onExtendedCssStyleSheetReceived(css) {
    { { DEBUG } } console.log(`ExtendedCss rules(length: ${css.length}) injecting for ${document.location.href}`);
    if (css.length > 0) {
      var extendedCss = new ExtendedCss({ styleSheet: css });
      extendedCss.apply();
    }
    { { DEBUG } } console.log(`ExtendedCss rules success for ${document.location.href}`);
    { { DEBUG } } console.log('element hiding finished');
  };
  