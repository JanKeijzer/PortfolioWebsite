// Open external links in new tab
function openExternalLinksInNewTab() {
  document.querySelectorAll('a[href^="http"]').forEach(function(link) {
    if (!link.href.includes(window.location.host)) {
      link.setAttribute('target', '_blank');
      link.setAttribute('rel', 'noopener noreferrer');
    }
  });
}

// Run on initial load
openExternalLinksInNewTab();

// Run after instant navigation (MkDocs Material)
document.addEventListener('DOMContentSwitch', openExternalLinksInNewTab);
