
document.head.insertAdjacentHTML(
  'beforeend',
  '<style>#outdated{text-align:center;position:fixed;bottom:0;width:100%;background:#2a2a2a;z-index:9999;font-size:14px;font-weight:300;color:#fff;padding:16px 0}#outdated h3{color: white;font-size:18px;line-height:27px}</style>'
);
var el = document.createElement('div');
el.setAttribute('id', 'outdated');
el.innerHTML =
  '<h3>Browser is not supported</h3><p>For a better experience, please keep your browser up to date.</p><p>Check <a id="btnUpdateBrowser" href="http://outdatedbrowser.com/">outdatedbrowser.com</a></p>';
document.body.appendChild(el);

