// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
if (window.addEventListener)
{
  window.addEventListener('load', initEventListeners, false);
}
else if (document.addEventListener)
{
  document.addEventListener('load', initEventListeners, false);
}
    
function initEventListeners()
{
  nav_more_links_handler();
  
  contextual_menu_toggle_button = $('contextual_menu_toggle_button');

  contextual_menu_toggle_button.addEventListener("click", function(){toggle_contextual_menu(contextual_menu_toggle_button)}, false);
  click_next(0);
}

function toggle_contextual_menu(item)
{
  position_hidden = "-210px";
  position_shown = "6px";
  width_shown = "200px";
  width_hidden = "0px";
  class_shown = "shown_contextual_menu";
  class_hidden = "hidden_contextual_menu";
  text_shown = "Cacher le menu";
  text_hidden = "Afficher le menu";

  if (item.className == class_shown)
  {
    document.body.style.overflowX = 'hidden';
    new Effect.Morph(item.parentNode, {
      style: {
        marginRight: position_hidden
      },
      duration: 1.5,
      afterFinish: function(){
        item.className = class_hidden;
        document.getElementById("status_text_contextual_menu").innerHTML = text_hidden;
      }
    });
  }
  else if (item.className == class_hidden)
  {
    document.body.style.overflowX = 'none';
    item.parentNode.style.width = width_shown;
    new Effect.Morph(item.parentNode, {
      style: {
        marginRight: position_shown
      },
      duration: 0.8,
      afterFinish: function(){
        item.className = class_shown;
        document.getElementById("status_text_contextual_menu").innerHTML = text_shown;
      }
    });
  }
}

function show_memorandum(element_or_position, value) {

  if (value == 0) {

    position = element_or_position.lastChild.id.lastIndexOf("_");
    id = element_or_position.lastChild.id.substr(position + 1);
  }

  else {
    memorandum = document.getElementsByClassName('position_'+element_or_position)[0]
    position = memorandum.id.lastIndexOf("_");
    id = memorandum.id.substr(position + 1);
  }

  document.location = "/received_memorandums/"+id
}

function change_memorandum(element, memorandum_number, event) {
  if (memorandum_number != 0 && memorandum_number !=1) {
    place = element.className.lastIndexOf("_");
    position = element.className.substr(place +1);
    
    document.getElementsByClassName('number')[0].innerHTML = " "+(parseInt(position))+" ";
    
    element_id = element.id
    
    if ((parseInt(position) - 1) == 0 ) {
      document.getElementById('previous').className = 'previous_memorandum_'+(parseInt(memorandum_number));
      if (element_id == 'next') {
        new Effect.Fade(document.getElementsByClassName('position_'+memorandum_number)[0], {duration: 0.3});
      }
    }
    else {
      document.getElementById('previous').className = 'previous_memorandum_'+(parseInt(position) - 1);
      if (element_id == 'next') {
        new Effect.Fade(document.getElementsByClassName('position_'+(parseInt(position) -1))[0], {duration: 0.3});
      }
    }
    
    if (parseInt(position) < memorandum_number) {
      document.getElementById('next').className = 'next_memorandum_'+(parseInt(position) + 1);
      if (element_id = 'previous') {
        new Effect.Fade(document.getElementsByClassName('position_'+(parseInt(position) +1))[0], {duration: 0.3});
      }
    }
    else {
      document.getElementById('next').className = 'next_memorandum_1';
      if (element_id = 'previous') {
        new Effect.Fade(document.getElementsByClassName('position_1')[0], {duration: 0.3});
      }
    }
    
    
    document.getElementById('text_under_banner').setAttribute('onclick', 'show_memorandum('+parseInt(position)+', 1)')
    new Effect.Appear(document.getElementsByClassName('position_'+position)[0], {duration: 2});
    refresh_timer()
    }
}
var timer

function click_next(value) {
  if (document.getElementsByClassName('number')[1] != null) {
    total_memorandum = document.getElementsByClassName('number')[1].innerHTML;

    if ( total_memorandum != 0 && total_memorandum != 1 ) {
      if (value == 0) {

        timer = setTimeout('click_next('+1+');', 15000);

      }
      else {
        document.getElementById('next').click();
      }
    }
  }
}

function refresh_timer() {
  clearTimeout(timer);
  timer = setTimeout('click_next('+1+');', 15000);
}

// permits to display the hidden menu when we click on the link
// and to hide it when we click elsewhere in the page.
function nav_more_links_handler() {
  more_links = $('nav').getElementsBySelector('a.nav_more')
  more_links.each(function(link) {
    Event.observe(link, 'click', function(menu_event) {
      menu = link.up('h4').nextSiblings().first()
      if (menu.getStyle('display') == 'none') {
        menu.setStyle({display:'block'})
      } else {
        Effect.toggle(menu, 'appear', {duration: 0.3})
      }
      
      Event.observe(window, 'mouseup', function(window_event) {
        if (menu.getStyle('display') != 'none') {
          Effect.toggle(menu, 'appear', {delay: 0.1, duration:0.3})
          Event.stop(window_event)
        }
      });
    });
  })
}

// Load the initial attributes of the document forms for the
// function preventClose, and active the autoresize for the
// targeted the textarea with class "text_area_autoresize"
Event.observe(window, 'load', function() {
  initializeAttributes();
  
  $$('.text_area-autoresize').each(function(textarea) {
    new Widget.Textarea(textarea);
  });    
});  

window.onbeforeunload = preventClose;
