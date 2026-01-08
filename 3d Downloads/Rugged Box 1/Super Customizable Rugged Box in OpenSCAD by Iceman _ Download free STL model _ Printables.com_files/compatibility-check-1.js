(function () {
  try {
    // test named Regexp groups and dotAll flag, these features are  required in addition to module support (already verified by nomodule import in index)
    eval("/(?<x>x)/ || new RegExp('x', 's')");
  } catch (e) {
    var scriptTag = document.createElement('script');
    scriptTag.setAttribute('src', '/scripts/outdated-1.js');
    document.body.appendChild(scriptTag);
  }
})();
