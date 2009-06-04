if (window.addEventListener)
{
  window.addEventListener('load', initOrderEventListeners, false);
}
else if (document.addEventListener)
{
  document.addEventListener('load', initOrderEventListeners, false);
}

function initOrderEventListeners() {
  initialize_toggle_order_header();
}

function initialize_toggle_order_header() {
  link = $('order_header_more').select('a').first();
  original_title_link = link.innerHTML;
  to_hide_title_link = "Réduire";
  
  Event.observe(link, 'click', function(menu_event) {
    if ($('order_header').select('.order_header_extra').first().getStyle('display') == "none") {
      new_text = to_hide_title_link;
      new_display = 'block';
    } else {
      new_text = original_title_link;
      new_display = 'none';
    }
    
    $('order_header').select('.order_header_extra').each(function(item) {
      item.setStyle({display: new_display});
    });
    link.innerHTML = new_text;
  });
}

function initialize_select_contact() {
  select = $('order_contact_ids')
  alert(select)
}
