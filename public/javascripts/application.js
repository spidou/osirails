// ADD PROTOTYPE METHODS
String.prototype.ltrim = function() { return this.replace(/^\s+/, ''); };
String.prototype.rtrim = function() { return this.replace(/\s+$/, ''); };
String.prototype.trim = function() { return this.ltrim().rtrim(); };

// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
if (window.addEventListener)
{
  window.addEventListener('load', initEventListeners, false);
  window.addEventListener('load', checkForCookies, false);
}
else if (document.addEventListener)
{
  document.addEventListener('load', initEventListeners, false);
  document.addEventListener('load', checkForCookies, false);
}

function initEventListeners()
{
  nav_more_links_handler();
  contextual_menu_toggle_button = $('contextual_menu_toggle_button');
  
  if (contextual_menu_toggle_button){
    contextual_menu_toggle_button.addEventListener("click", function(){toggle_contextual_menu(contextual_menu_toggle_button)}, false);
    click_next(0);
  }
}

// function to check for cookies
//
function checkForCookies()
{
  if($('contextual_menu_container') == null) return;
  
  var pin_status = GetCookieValue('pin_status');
  if (pin_status == 'pinned'){
    $('content_page').setAttribute('class','with_pinned_menu');
    $('contextual_menu_toggle_button').hide();
    $('reduce_button_link').hide()
  }
  else{
    toggle_contextual_menu($('contextual_menu_toggle_button'));
  }
}


// function to set a cookie
//
function setCookie(name, value, expires, path, domain, secure)
{
	document.cookie=name +"="+ escape(value) +
		(expires ? ("; expires="+ expires.toGMTString()) : '') +
		(path    ? ("; path="+ path) : '') +
		(domain  ? ("; domain="+ domain) : '') +
		(secure==true ? "; secure" : '');
}


// function to get a cookie's value
// go to toutjavascript.com for more precision about ways to get a cookie
//
function GetCookieValue(name)
{
  var cookie = document.cookie.split(name+"=")[1]
  if(cookie){
    return cookie.split(';')[0]; // get the element between 'name=' and ';' because the cookie is like that "name=value; ..."
  }
  return null;
}



function toggle_pin_contextual_menu(item)
{
  var message1 = 'Détacher le menu';
  var message2 = 'Épingler le menu';
  var image1 = 'pinned_16x16.png';
  var image2 = 'not_pinned_16x16.png';
  
  var exp_date = new Date( 2038 , 1, 1 ); // the year is set to 2038 to simule never expire behavior FIXME this is due to the unix timestamps limit with 32 bit based system
  var image = item.down('img')
  var image_prefix = image.getAttribute('src').substring(0, image.getAttribute('src').lastIndexOf('/') + 1)
  
  if($('contextual_menu_container').className == 'not_pinned_menu')
  {
    $('contextual_menu_container').setAttribute('class', 'pinned_menu');
    $('content_page').setAttribute('class','with_pinned_menu');
    image.setAttribute('src', image_prefix + image1)
    image.setAttribute('title', message1)
    image.setAttribute('alt', message1)
    
    setCookie('pin_status', 'pinned', exp_date, '/');
  }
  else
  {
    $('contextual_menu_container').setAttribute('class', 'not_pinned_menu');
    $('content_page').setAttribute('class','');
    image.setAttribute('src', image_prefix + image2)
    image.setAttribute('title', message2)
    image.setAttribute('alt', message2)
    
    setCookie('pin_status', 'not_pinned', exp_date, '/');
  }
  
  $('reduce_button_link').toggle();
}

function toggle_contextual_menu(item)
{
  class_shown = "shown_contextual_menu";
  class_hidden = "hidden_contextual_menu";
  
  if (item.className == class_shown)
  {
    container_width = parseInt( $('contextual_menu_container').getStyle('width') )
    container_right = parseInt( $('contextual_menu_container').getStyle('right') )
    status_position = $('status_background_contextual_menu').getStyle('position')
    menu_display    = $('contextual_menu').getStyle('display')
    menu_position   = $('contextual_menu').getStyle('position')
    menu_right      = $('contextual_menu').getStyle('right')
    
    document.body.style.overflowX = 'hidden';
    new Effect.Morph($('contextual_menu_container'), {
      style: {
        marginRight: "-"+(container_width+container_right)+"px"
      },
      duration: 0.6,
      afterFinish: function(){
        $('contextual_menu_container').setAttribute('style','witdh:0px;position:absolute;right:0px');
        $('contextual_menu').setStyle({display: 'none'})
        item.setAttribute('style','position:relative;right:0px');   
        item.className = class_hidden;
        document.body.style.overflowX = 'auto';
      }
    });
  }
  else if (item.className == class_hidden)
  {
    $('contextual_menu_container').setAttribute('style','witdh:0px;position:absolute;right:-'+(container_width-2)+'px');
    $('contextual_menu').setAttribute('style','display:'+menu_display+';position:'+menu_position+';right:'+menu_right);
    
    document.body.style.overflowX = 'hidden';
    new Effect.Morph($('contextual_menu_container'), {
      style: {
        marginRight: (container_width+container_right)+"px"
      },
      duration: 0.4,
      afterFinish: function(){
        $('contextual_menu_container').setAttribute('style','right:'+container_right+'px');
        item.className = class_shown;
        document.body.style.overflowX = 'auto';
      }
    });
  }
  $('contextual_menu_toggle_button').toggle();
  $('contextual_menu_actions').toggle();
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
      $('previous').className = 'previous_memorandum_'+(parseInt(memorandum_number));
      if (element_id == 'next') {
        new Effect.Fade(document.getElementsByClassName('position_'+memorandum_number)[0], {duration: 0.3});
      }
    }
    else {
      $('previous').className = 'previous_memorandum_'+(parseInt(position) - 1);
      if (element_id == 'next') {
        new Effect.Fade(document.getElementsByClassName('position_'+(parseInt(position) -1))[0], {duration: 0.3});
      }
    }
    
    if (parseInt(position) < memorandum_number) {
      $('next').className = 'next_memorandum_'+(parseInt(position) + 1);
      if (element_id = 'previous') {
        new Effect.Fade(document.getElementsByClassName('position_'+(parseInt(position) +1))[0], {duration: 0.3});
      }
    }
    else {
      $('next').className = 'next_memorandum_1';
      if (element_id = 'previous') {
        new Effect.Fade(document.getElementsByClassName('position_1')[0], {duration: 0.3});
      }
    }
    
    
    $('text_under_banner').setAttribute('onclick', 'show_memorandum('+parseInt(position)+', 1)')
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
        if( $('next') != null ) { $('next').click(); }
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
  more_links = $('nav').select('a.nav_more')
  more_links.each(function(link) {
    Event.observe(link, 'click', function(menu_event) {
      h4 = link.up('h4')
      menu = h4.nextSiblings().first()
      if (menu.getStyle('display') == 'none') {
        menu.setStyle({left: h4.offsetLeft+'px', display: 'block'})
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

function prepare_ajax_holder() {
  clean_ajax_holder_content()
  
  holder = $('ajax_holder')
  holder.show()
  
  ajax_holder_loading()
}

function ajax_holder_loading() {
  loader = $('ajax_holder_waiting')
  loader.show()
}

function ajax_holder_loaded() {
  loader = $('ajax_holder_waiting')
  loader.hide()
  
  display_ajax_holder_content()
}

function clean_ajax_holder_content() {
  $('ajax_holder_content').hide()
}

function display_ajax_holder_content() {
  new Effect.Appear('ajax_holder_content')
}

function close_ajax_holder() {
  new Effect.Fade('ajax_holder', { duration:'0.3', afterFinish:function(){ clean_ajax_holder_content()} })
}

function initialize_autoresize_text_areas() {
  $$('.autoresize_text_area').each(function(textarea) {
    new Widget.Textarea(textarea);
  });
}

// Load the initial attributes of the document forms for
// the function preventClose, active the autoresize for the
// targeted textarea with class "autoresize_text_area" and
// initialize javascript time functions
Event.observe(window, 'load', function() {
  initializeAttributes();
  initialize_autoresize_text_areas();
  initialize_time();
  display_time();
});  

// Avoid the prevent close message if the action is called
// by a submit button

Event.observe(window, 'submit', function(ev) {
  window.onbeforeunload = null; 
});

window.onbeforeunload = preventClose;
