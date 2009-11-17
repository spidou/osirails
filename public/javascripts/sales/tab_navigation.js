if (window.addEventListener)
{
  window.addEventListener('load', initOrderEventListeners, false);
}
else if (document.addEventListener)
{
  document.addEventListener('load', initOrderEventListeners, false);
}

function initOrderEventListeners() {
  initialize_tab_navigation();
}

all_section = null

function initialize_tab_navigation() {
  $$('.tab_nav').each( function(ul_nav) {
    ul_nav.childElements().each( function(li) {
      if (!li.hasClassName('disabled')) {
        li.addEventListener('click', click_on_li_nav, false)
      }
      li.onmousedown   = function() { return false; } // disable text selection (Firefox)
      li.onselectstart = function() { return false; } // disable text selection (IE)
    })
  })
}

function click_on_li_nav(event) {
  li = event.target
  //product = null
  section = null
  
  // get section name to display or hide
  section = li.classNames().toArray(' ')[0]
  if (section == null) { alert("An error has occured. The element you clicked should have at least a className. Please contact your administrator"); return; }
  
  section_div = li.up('.root_nav').down('div.' + section)
  if (section_div == null) { alert("An error has occured. Impossible to find a div with the given class '" + section + "'. Please contact your administrator"); return; }
  
  if (!li.hasClassName('selected')) {
    // remove 'selected' class on previously selected element, and add it on newly selected element
    li.siblings().each( function(sibling) {
      sibling.removeClassName('selected')
    })
    li.addClassName('selected')
    
    if (section_div) {
      // hide previously selected section
      section_div.siblings().each( function(sibling) {
        if (sibling != section_div && sibling.tagName == "DIV") {
          sibling.removeClassName('selected')
        }
      })
      
      // display the newly selected section
      section_div.addClassName('selected')
    } else {
      
    }
  } else {
    // remove selected class on clicked element
    li.removeClassName('selected')
    
    // remove selected class on selected section
    section_div.removeClassName('selected')
  }
}
