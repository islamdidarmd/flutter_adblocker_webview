(function () {
  { { DEBUG } } console.log('element hiding started on ' + document.location.href);
  // hide by injecting CSS
  GetStyleSheet.postMessage(document.location.href);
}
)();