// Call scriptles
(function () {
{ { DEBUG } } console.log('Getting scriptlets');
GetScriptlets.postMessage(document.location.href);
}
)();

// Receive scriptlets
(function () {
    var scriptletArray = JSON.parse({{ param }});

    for (let item of scriptletArray) {
        let script = scriptlets.invoke({
            name: item[0],
            args: item.slice(1)
        });
    
        { { DEBUG } } !script && console.log(`invalid scriptlets: ${JSON.stringify(item)}`);
    
        try {
            // don't use eval() here, it may be blocked by scriptlets
            new Function(script)();
        } catch (err) {
            { { DEBUG } } console.log('scriptlets went wrong: ' + err);
            throw err;
        }
    }
    {{DEBUG}} console.log(`applied ${scriptletArray.length} scriptlets for ${document.location.href}`);
})();
