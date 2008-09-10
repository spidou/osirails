// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function toggle_secondary_menu(item)
{
  position_shown = "-210px";
  position_hidden = "6px";
  class_shown = "shown_secondary_menu";
  class_hidden = "hidden_secondary_menu";
  //alert(item)
  if (item.className == class_shown)
  {
    new Effect.Morph(item.parentNode, {
      style: {
        marginRight: position_shown
      },
      duration: 1.5
    });
    item.className = class_hidden;
    document.getElementById("status_text_secondary_menu").innerHTML = "Afficher le menu"
    document.body.style.overflowX = 'hidden'
  }
  else if (item.className == class_hidden)
  {
    new Effect.Morph(item.parentNode, {
      style: {
        marginRight: position_hidden
      },
      duration: 1.5,
      className: class_shown
    });
    item.className = class_shown;
    document.getElementById("status_text_secondary_menu").innerHTML = "Cacher le menu"
    document.body.style.overflowX = 'none'
  }
}