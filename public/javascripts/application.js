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
  secondary_menu_toggle_button = document.getElementById('secondary_menu_toggle_button');
  under_banner = document.getElementById('text_under_banner');

  secondary_menu_toggle_button.addEventListener("click", function(){toggle_secondary_menu(secondary_menu_toggle_button)}, false);
  refresh_memorandum(under_banner)
}

function toggle_secondary_menu(item)
{
  position_hidden = "-210px";
  position_shown = "6px";
  width_shown = "200px";
  width_hidden = "0px";
  class_shown = "shown_secondary_menu";
  class_hidden = "hidden_secondary_menu";
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
        document.getElementById("status_text_secondary_menu").innerHTML = text_hidden;
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
        document.getElementById("status_text_secondary_menu").innerHTML = text_shown;
      }
    });
  }
}

function refresh_memorandum(element) {
  children = element.childNodes
  tab = new Array
  for (i = 0; i < children.length; i++) {
    tab[i] = children[i]
  }
  
//  for (i = 0; i < tab.length; i++) {
//  new Effect.Fade(tab[i], {duration: 2});
//  }
}

function show_memorandum(element) {

  position = element.id.lastIndexOf("_");
  id = element.id.substr(position + 1);
  
  document.location = "/received_memorandums/"+id
}

function next_memorandum(element, memorandum_number) {

    place = element.className.lastIndexOf("_");
    position = element.className.substr(place + 1);
    
    document.getElementsByClassName('number')[0].innerHTML = " "+(parseInt(position))+" " ;
    
    if ((position - 1) == 0 ) {
    document.getElementById('previous').className = 'previous_memorandum_'+parseInt(memorandum_number);
    new Effect.Fade(document.getElementsByClassName('position_'+memorandum_number)[0], {duration: 0.3});
    }
    else {
    document.getElementById('previous').className = 'previous_memorandum_'+parseInt(position - 1);
    new Effect.Fade(document.getElementsByClassName('position_'+(parseInt(position) -1))[0], {duration: 0.3});
    }

    if (position < memorandum_number) {

    document.getElementById('next').className = 'next_memorandum_'+(parseInt(position) + 1);
    }
    else {
    document.getElementById('next').className = 'next_memorandum_1';
    }
    
    new Effect.Appear(document.getElementsByClassName('position_'+position)[0], {duration: 2});
}

function previous_memorandum(element, memorandum_number) {

    place = element.className.lastIndexOf("_");
    position = element.className.substr(place + 1);
    
    document.getElementsByClassName('number')[0].innerHTML = " "+parseInt(position)+" " ;
    
    if ((parseInt(position) -1) == 0) {
    document.getElementById('previous').className = 'previous_memorandum_'+(parseInt(memorandum_number));
    }
    else {
    document.getElementById('previous').className = 'previous_memorandum_'+(parseInt(position) -1);
    }
    
    if (parseInt(position) != memorandum_number) {
    document.getElementById('next').className = 'next_memorandum_'+(parseInt(position) +1);
    new Effect.Fade(document.getElementsByClassName('position_'+(parseInt(position) +1))[0], {duration: 0.3});
    }
    else {
    document.getElementById('next').className = 'next_memorandum_1';
    new Effect.Fade(document.getElementsByClassName('position_1')[0], {duration: 0.3});
    }
    
    new Effect.Appear(document.getElementsByClassName('position_'+position)[0], {duration: 2});
}

