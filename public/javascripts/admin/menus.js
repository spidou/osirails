function tick_children(object) {
  var element = $(object)
  var li_element = element.up('.category');
  
  if (element.checked == false) {
    element.previous('.method').addClassName('unchecked')
    var ul_element = li_element.next();
    
    if (ul_element != null && ul_element.tagName=='UL') {
      var children = ul_element.descendants();
      
      for (var i = 0; i < children.size(); i++ ) {
        var child = children[i];
        if (child.className == 'check_boxes') {
          child.checked = false;
          child.previous('.method').addClassName('unchecked');
        }
      }
    }
  } else {
    element.previous('.method').removeClassName('unchecked');
    var parents = li_element.ancestors();
    
    if (parents != 'undefined'){
      for (var i = 0; i < parents.size(); i++ ) {
        var parent = parents[i];
        
        if (parent.tagName == 'UL' && parent.previous() != null) {
          parent.previous().down('.check_boxes').checked = true;
          parent.previous().down('.method').removeClassName('unchecked');
        }
      }
    }
  }
}
