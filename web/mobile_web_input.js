// Phone browsers keep a layout viewport that is taller/wider than what the
// user can tap (Safari/Chrome toolbars, visualViewport offset, residual zoom).
// Flutter then paints widgets where they cannot receive pointer events — most
// visibly the bottom strip and the top-right AppBar. "Request desktop site"
// avoids that by using a different viewport and UA. This script keeps the
// document glued to the *visible* viewport instead.
(function () {
  'use strict';

  var PLACEHOLDER = 'flt-semantics-placeholder';
  var VIEWPORT_CONTENT =
    'width=device-width, initial-scale=1.0, viewport-fit=cover';
  var observed = typeof WeakSet === 'function' ? new WeakSet() : null;
  var fitScheduled = false;
  var fitting = false;

  function resetViewportScroll() {
    window.scrollTo(0, 0);
    if (document.documentElement) document.documentElement.scrollTop = 0;
    if (document.body) document.body.scrollTop = 0;
  }

  function setStyle(el, prop, value) {
    if (el.style[prop] === value) return false;
    el.style[prop] = value;
    return true;
  }

  function fitToVisualViewport() {
    if (fitting) return;
    var vv = window.visualViewport;
    var width = vv && vv.width ? vv.width : window.innerWidth;
    var height = vv && vv.height ? vv.height : window.innerHeight;
    var left = vv ? vv.offsetLeft : 0;
    var top = vv ? vv.offsetTop : 0;
    if (!width || !height) return;

    fitting = true;
    var html = document.documentElement;
    var body = document.body;
    var widthPx = Math.round(width * 1000) / 1000 + 'px';
    var heightPx = Math.round(height * 1000) / 1000 + 'px';
    var leftPx = Math.round(left * 1000) / 1000 + 'px';
    var topPx = Math.round(top * 1000) / 1000 + 'px';

    if (html) {
      setStyle(html, 'width', widthPx);
      setStyle(html, 'height', heightPx);
      setStyle(html, 'overflow', 'hidden');
    }
    if (body) {
      setStyle(body, 'position', 'fixed');
      setStyle(body, 'margin', '0px');
      setStyle(body, 'overflow', 'hidden');
      setStyle(body, 'width', widthPx);
      setStyle(body, 'height', heightPx);
      setStyle(body, 'left', leftPx);
      setStyle(body, 'top', topPx);
      setStyle(body, 'right', 'auto');
      setStyle(body, 'bottom', 'auto');
    }

    resetViewportScroll();
    fitting = false;
  }

  function scheduleFit() {
    if (fitScheduled) return;
    fitScheduled = true;
    requestAnimationFrame(function () {
      fitScheduled = false;
      fitToVisualViewport();
    });
  }

  function ensureViewportMeta() {
    var head = document.head;
    if (!head) return;
    var metas = document.querySelectorAll('meta[name="viewport"]');
    if (!metas.length) {
      var created = document.createElement('meta');
      created.setAttribute('name', 'viewport');
      created.setAttribute('content', VIEWPORT_CONTENT);
      head.appendChild(created);
      return;
    }
    for (var i = 0; i < metas.length; i++) {
      if (metas[i].getAttribute('content') !== VIEWPORT_CONTENT) {
        metas[i].setAttribute('content', VIEWPORT_CONTENT);
      }
    }
  }

  function isPlaceholder(node) {
    if (!node || node.nodeType !== 1) return false;
    var name = node.localName || node.nodeName;
    return name === PLACEHOLDER || name === PLACEHOLDER.toUpperCase();
  }

  function neutralizePlaceholder(el) {
    el.setAttribute('tabindex', '-1');
    el.style.setProperty('pointer-events', 'none', 'important');
    el.style.setProperty('display', 'none', 'important');
    if (el.remove) el.remove();
  }

  function walk(root) {
    if (!root) return;
    if (isPlaceholder(root)) {
      neutralizePlaceholder(root);
      return;
    }
    var shadow = root.shadowRoot;
    if (shadow) {
      observe(shadow);
      walk(shadow);
    }
    var children = root.children;
    if (!children) return;
    for (var i = 0; i < children.length; i++) {
      walk(children[i]);
    }
  }

  function observe(root) {
    if (!root || (observed && observed.has(root))) return;
    if (observed) observed.add(root);
    var observer = new MutationObserver(function (mutations) {
      for (var i = 0; i < mutations.length; i++) {
        var added = mutations[i].addedNodes;
        for (var j = 0; j < added.length; j++) {
          walk(added[j]);
        }
      }
    });
    observer.observe(root, { childList: true, subtree: true });
  }

  function install() {
    ensureViewportMeta();
    observe(document);
    if (document.documentElement) walk(document.documentElement);
    scheduleFit();
  }

  install();
  window.addEventListener('load', install);
  window.addEventListener('pageshow', install);
  window.addEventListener('resize', scheduleFit);
  window.addEventListener('orientationchange', install);
  window.addEventListener('flutter-first-frame', install);
  window.addEventListener('focusout', scheduleFit, true);
  document.addEventListener('visibilitychange', function () {
    if (!document.hidden) install();
  });
  // iOS does not always deliver the first touch unless a listener exists.
  window.addEventListener('touchstart', function () {}, {
    capture: true,
    passive: true,
  });
  if (window.visualViewport) {
    window.visualViewport.addEventListener('resize', scheduleFit);
    window.visualViewport.addEventListener('scroll', scheduleFit);
  }
})();
