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
  class_shown = "shown_contextual_menu";
  class_hidden = "hidden_contextual_menu";
  text_shown = "Cacher le menu";
  text_hidden = "Afficher le menu";
  if (item.className == class_shown)
  {
    container_width = $('contextual_menu_container').offsetWidth;
    document.body.style.overflowX = 'hidden';
    new Effect.Morph($('contextual_menu_container'), {
      style: {
        marginRight: "-"+container_width-13+"px"
      },
      duration: 1,
      afterFinish: function(){   
        $('status_background_contextual_menu').setAttribute('style','witdh:0px;position:relative;right:0px');
        $('contextual_menu_container').setAttribute('style','witdh:0px;position:absolute;right:0px');     
        $('contextual_menu').setAttribute('style','display:none');
        item.setAttribute('style','position:relative;right:0px');   
        document.body.style.overflowX = 'auto';
        item.className = class_hidden;
        document.getElementById("status_text_contextual_menu").innerHTML = text_hidden;
      }
    });
  }
  else if (item.className == class_hidden)
  {
    $('status_background_contextual_menu').setAttribute('style','witdh:0px;position:relative');
    $('contextual_menu_container').setAttribute('style','witdh:0px;position:absolute;right:-'+(container_width-2)+'px');
    $('contextual_menu').setAttribute('style','display:block;position:relative;right:0px');
    document.body.style.overflowX = 'hidden';
    new Effect.Morph($('contextual_menu_container'), {
      style: {
        marginRight: container_width+13+"px"
      },
      duration: 0.8,
      afterFinish: function(){
        $('contextual_menu_container').setAttribute('style','right:15px');
        document.body.style.overflowX = 'auto';
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

// Load the initial attributes of the document forms for
// the function preventClose, active the autoresize for the
// targeted textarea with class "autoresize_text_area" and
// initialize javascript time functions
Event.observe(window, 'load', function() {
  initializeAttributes();
  
  $$('.autoresize_text_area').each(function(textarea) {
    new Widget.Textarea(textarea);
  });
  initialize_time();
  display_time();
});  

// Avoid the prevent close message if the action is called
// by a submit button

Event.observe(window, 'submit', function(ev) {
  window.onbeforeunload = null; 
});

window.onbeforeunload = preventClose;
