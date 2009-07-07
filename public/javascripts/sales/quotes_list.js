if (window.addEventListener)
{
  window.addEventListener('load', initQuotesListEventListeners, false);
}
else if (document.addEventListener)
{
  document.addEventListener('load', initQuotesListEventListeners, false);
}

function initQuotesListEventListeners() {
  initialize_toggle_quotes_list_more_infos();
}

function initialize_toggle_quotes_list_more_infos() {
  link = $('quotes_list_more_infos_link');
  original_title_link = link.innerHTML;
  to_hide_title_link = "Cacher";
  element = $('quotes_list_more_infos')
  
  Event.observe(link, 'click', function(menu_event) {
    if (element.getStyle('display') == "none") {
      new_text = to_hide_title_link;
    } else {
      new_text = original_title_link;
    }
    
    Effect.toggle(element, 'blind', { afterFinish: function(){ link.innerHTML = new_text } })
  });
}
