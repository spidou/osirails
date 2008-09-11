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
  secondary_menu_toggle_button = document.getElementById('secondary_menu_toggle_button')
  secondary_menu_toggle_button.addEventListener("click", function(){toggle_secondary_menu(secondary_menu_toggle_button)}, false);
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