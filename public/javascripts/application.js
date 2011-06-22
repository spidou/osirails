// ADD PROTOTYPE METHODS
String.prototype.ltrim = function() { return this.replace(/^\s+/, ''); };
String.prototype.rtrim = function() { return this.replace(/\s+$/, ''); };
String.prototype.trim = function() { return this.ltrim().rtrim(); };
String.prototype.toBoolean = function() { return "true" == this; };
String.prototype.multiply = function(times) {
  var value = ""
  for (var i = 0; i < times; i++) value += this
  return value;
};
String.prototype.ljust = function(padSize, padStr) { // eg: "hello".ljust(10, "123")
  var pad = padStr.multiply(padSize - this.length)   //     => pad = "123123123123123"
  pad = pad.substr(0, pad.length/padStr.length)      //     => pad = "12312"
  return this + pad                                  //     => "hello12312"
};
String.prototype.rjust = function(padSize, padStr) {
  var pad = padStr.multiply(padSize - this.length)
  pad = pad.substr(0, pad.length/padStr.length)
  return pad + this
};

Array.prototype.sum = function() { return this.inject(0, function(a,b){ return a + b }); };

// Add Enumerable to NamedNodeMap (used when calling $('dom_id').attributes)
Object.extend(NamedNodeMap.prototype, Enumerable);
Object.extend(NamedNodeMap.prototype, {
  _each: function(iterator) {
    for (var i = 0; i < this.length; i++)
      iterator(this[i]);
  },
  
  names: function() {
    return this.collect(function(a){return a.name})
  },
  
  values: function() {
    return this.collect(function(a){return a.value})
  }
});

function log(msg) {
  try {
    console.log(msg);
  } catch(er) {
    try {
      window.opera.postError(msg);
    } catch(er) {
     //no console avaliable. put 
     //alert(msg) here or write to a document node or just ignore
    }
  }
}

function warn(msg) {
  try {
    console.warn(msg);
  } catch(er) {
    try {
      window.opera.postError(msg);
    } catch(er) {
     //no console avaliable. put 
     //alert(msg) here or write to a document node or just ignore
    }
  }
}

function error(msg) {
  try {
    console.error(msg);
  } catch(er) {
    try {
      window.opera.postError(msg);
    } catch(er) {
     //no console avaliable. put 
     //alert(msg) here or write to a document node or just ignore
    }
  }
}

// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
if (window.addEventListener)
{
  window.addEventListener('load', initEventListeners, false);
  window.addEventListener('load', checkForCookies, false);
  window.addEventListener('load', prepare_variables_for_contextual_menu, false);
}
else if (document.addEventListener)
{
  document.addEventListener('load', initEventListeners, false);
  document.addEventListener('load', checkForCookies, false);
  document.addEventListener('load', prepare_variables_for_contextual_menu, false);
}

function initEventListeners()
{
  nav_more_links_handler();
  contextual_menu_toggle_button = $('contextual_menu_toggle_button');
  
  if (contextual_menu_toggle_button){
    contextual_menu_toggle_button.addEventListener("click", function(){toggle_contextual_menu(contextual_menu_toggle_button)}, false);
    refresh_timer();
  }
}

// function to check for cookies
//
function checkForCookies()
{
  if ($('contextual_menu_container') == null) return;
  
  var pin_status = GetCookieValue('pin_status');
  if (pin_status != 'pinned')
    toggle_contextual_menu($('contextual_menu_toggle_button'));
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

// prepare variables for pin and unpin contextual_menu functions
function prepare_variables_for_contextual_menu()
{
  if ($('contextual_menu_container') == null) return;  
  unpin_message     = 'Détacher le menu';
  pin_message       = 'Épingler le menu';
  pinned_image      = 'pinned_16x16.png';
  unpinned_image    = 'not_pinned_16x16.png';
  pin_image         = $('pin_button_link').down('img')
  pin_image_prefix  = pin_image.getAttribute('src').substring(0, pin_image.getAttribute('src').lastIndexOf('/') + 1)
  exp_date          = new Date( 2038 , 1, 1 ); // the year is set to 2038 to simule never expire behavior FIXME this is due to the unix timestamps limit with 32 bit based system
}

function pin_contextual_menu()
{
  $('contextual_menu_container').setAttribute('class', 'pinned_menu');
  $('content_page').setAttribute('class','with_pinned_menu');
  pin_image.setAttribute('src', pin_image_prefix + pinned_image)
  pin_image.setAttribute('title', unpin_message)
  pin_image.setAttribute('alt', unpin_message)
  
  setCookie('pin_status', 'pinned', exp_date, '/');
}

function unpin_contextual_menu()
{
  $('contextual_menu_container').setAttribute('class', 'not_pinned_menu');
  $('content_page').setAttribute('class','');
  pin_image.setAttribute('src', pin_image_prefix + unpinned_image)
  pin_image.setAttribute('title', pin_message)
  pin_image.setAttribute('alt', pin_message)
  
  setCookie('pin_status', 'not_pinned', exp_date, '/');
}

function toggle_pin_contextual_menu()
{
  if($('contextual_menu_container').className == 'not_pinned_menu') {
    pin_contextual_menu();
  }
  else {
    unpin_contextual_menu();
  }
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
        $('contextual_menu').hide();
        item.setAttribute('style','position:relative;right:0px');   
        item.className = class_hidden;
        document.body.style.overflowX = 'auto';
        $('contextual_menu_toggle_button').show();
      }
    });
  }
  else if (item.className == class_hidden)
  {
    $('contextual_menu_container').setAttribute('style','witdh:0px;position:absolute;right:-'+(container_width-2)+'px');
    $('contextual_menu').setAttribute('style','display:'+menu_display+';position:'+menu_position+';right:'+menu_right);
    $('contextual_menu_toggle_button').hide();
    
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

function change_memorandum(element) {
  if (memorandum_count > 1) {
    place = element.className.lastIndexOf("_");
    position = element.className.substr(place +1);
    
    document.getElementsByClassName('number')[0].innerHTML = " "+(parseInt(position))+" ";
    
    element_id = element.id
    
    if ((parseInt(position) - 1) == 0 ) {
      $('previous_memorandum').className = 'previous_memorandum_'+(parseInt(memorandum_count));
      if (element_id == 'next_memorandum') {
        new Effect.Fade(document.getElementsByClassName('position_'+memorandum_count)[0], {duration: 0.3});
      }
    }
    else {
      $('previous_memorandum').className = 'previous_memorandum_'+(parseInt(position) - 1);
      if (element_id == 'next_memorandum') {
        new Effect.Fade(document.getElementsByClassName('position_'+(parseInt(position) -1))[0], {duration: 0.3});
      }
    }
    
    if (parseInt(position) < memorandum_count) {
      $('next_memorandum').className = 'next_memorandum_'+(parseInt(position) + 1);
      if (element_id = 'previous_memorandum') {
        new Effect.Fade(document.getElementsByClassName('position_'+(parseInt(position) +1))[0], {duration: 0.3});
      }
    }
    else {
      $('next_memorandum').className = 'next_memorandum_1';
      if (element_id = 'previous_memorandum') {
        new Effect.Fade(document.getElementsByClassName('position_1')[0], {duration: 0.3});
      }
    }
    
    
    $('text_under_banner').setAttribute('onclick', 'show_memorandum('+parseInt(position)+', 1)')
    new Effect.Appear(document.getElementsByClassName('position_'+position)[0], {duration: 2});
    refresh_timer()
  }
}


var timer
function refresh_timer() {
  clearTimeout(timer);
  if (typeof(memorandum_count) != 'undefined')
    timer = setTimeout(function(){ change_memorandum($('next_memorandum')) }, 15000)
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
          Event.stop(window_event) //FIXME doesn't seem to work
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

// Method to automatically restore a value on a readonly field
function restore_readonly_value(event){
  target = event.target
  if (target.tagName == "SELECT")
    target.selectedIndex = target.readAttribute('data-readonly-value')
  else if (target.tagName == "INPUT" && target.type == "checkbox")
    target.checked = target.readAttribute('data-readonly-value').toBoolean()
}
var bind_restore_readonly_value = restore_readonly_value.bindAsEventListener(null)

// Add readonly behaviour on some form fields
function enable_readonly_fields() {
  $$('select, input[type=checkbox]').each(function(field){
    Event.observe(field, 'focus', function(event){
      if (field.readAttribute('readonly') == 'readonly') {
        if (field.tagName == "SELECT")
          field.writeAttribute('data-readonly-value', field.selectedIndex)
        else if (field.tagName == "INPUT" && field.type == "checkbox")
          field.writeAttribute('data-readonly-value', field.checked.toString());
        
        // here we may find a way to store orginal observers (only 'onchange' ones), in order to restore them if in the future the field is not readonly anymore
        field.stopObserving('change') // yeah we remove 'onchange' observers because a readonly field is not supposed to change!
        
        field.observe('change', bind_restore_readonly_value)
      }
    });
    
    Event.observe(field, 'blur', function(event){
      event.target.stopObserving('change', bind_restore_readonly_value)
    });
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
  enable_readonly_fields();
});  

// Avoid the prevent close message if the action is called by a form submit
Event.observe(window, 'submit', function(ev) {
  window.onbeforeunload = null; 
});
window.onbeforeunload = preventClose;

// Add an ajax indicator for all Ajax call
var ajax_indicator_timer;
Ajax.Responders.register({
  onCreate: function() {
    clearTimeout(ajax_indicator_timer)
    ajax_indicator_timer = setTimeout(function(){ new Effect.Appear('ajax_indicator', { duration: 0.2 }) }, 700);
  },
  onComplete: function() {
    if (0 == Ajax.activeRequestCount) {
      new Effect.Fade('ajax_indicator', { duration: 0.5 });
      clearTimeout(ajax_indicator_timer);
    }
  }
});

// return the string of the float rounded with the specified precision, keeping zeros according to the precision
// x = 109.4687
// roundNumber(x, 1) => 109.5
//
// x = 109.6
// roundNumber(x, 3) => 109.600
function roundNumber(number, precision) {
  precision = parseInt(precision)
	var result = Math.round(parseFloat(number) * Math.pow(10, precision)) / Math.pow(10, precision)
	var str_result = result.toString()
	delimiter = str_result.indexOf(".")
	if (delimiter > 0) {
	  var integer = str_result.substring(0, delimiter)
	  var decimals = str_result.substring(delimiter + 1, str_result.length)
	  if (decimals.length < precision) {
	    for (i = decimals.length; i < precision; i++) {
	      decimals += "0"
	    }
	  }
	  str_result = integer + "." + decimals
	} else {
	  str_result += ".00"
	}
	return str_result
}

var OsirailsBase = Class.create({
  //initialize: function(){
  //
  //},
  
  //TODO include method 'roundNumber' here
})

var TableLine = {
  
  init_table_line_observers: function() {
    this.bind_move_up = this.bind_move_up || this.move_up.bindAsEventListener(this)
    this.bind_move_down = this.bind_move_down || this.move_down.bindAsEventListener(this)
    
    // remove old observers
    this.move_up_button().stopObserving('click', this.bind_move_up)
    this.move_down_button().stopObserving('click', this.bind_move_down)
    
    // add observers
    this.move_up_button().observe('click', this.bind_move_up)
    this.move_down_button().observe('click', this.bind_move_down)
  },
  
  move_up: function() {
    this.move_tr(true);
  },
  
  move_down: function() {
    this.move_tr(false);
  },
  
  move_tr: function(to_up) {
    var element   = this.root;
    var neighbour = $(this.nearly_visible(to_up, element));
    
    if (neighbour == null) return;
    
    (to_up ? neighbour.insert({before: element}) : neighbour.insert({after: element}) );
    this.highlight()
    
    this.udpate_and_sort_items()
    this.update_up_down_links()
  },
  
  // Method the parse next or previous siblings until the first visible, and return it
  //
  nearly_visible: function(to_up, element) {
    do { element = (to_up ? element.previous() : element.next()) }
    while(element != null && !element.visible())
    return element;
  },
  
  is_first: function() {
    return this.position() == 1
  },
  
  is_last: function() {
    return this.position() == this.self_and_siblings().size()
  },
  
  update_up_down_links: function() {
    this.enable_up_down_buttons()
    
    if (this.is_first())
      this.disable_up_button()
    if (this.is_last())
      this.disable_down_button()
  },
  
  enable_up_down_buttons: function() {
    this.enable_up_button()
    this.enable_down_button()
  },
  
  enable_up_button: function() {
    this.move_up_button().removeClassName('disabled')
  },
  
  enable_down_button: function() {
    this.move_down_button().removeClassName('disabled')
  },
  
  disable_up_button: function() {
    this.move_up_button().addClassName('disabled')
  },
  
  disable_down_button: function() {
    this.move_down_button().addClassName('disabled')
  },
  
  highlight: function() {
    this.highlight_element(this.root)
  }
}
