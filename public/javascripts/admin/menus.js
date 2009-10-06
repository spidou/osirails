function tick_children(object)
{
  var li_element = $(object).up('.category');
  if ($(object).checked == false){
    $(object).previous('.method').className = 'method unChecked';
    var ul_element = li_element.next();
    
    if(ul_element != null && ul_element.tagName=='UL'){
      var elements = ul_element.descendants();
      
      for( var i=0; i<elements.size(); i++ ){
        var element = elements[i];
        if(element.className == 'check_boxes'){
          element.checked = false;
          element.previous('.method').className = 'method unChecked';
        }
        
      }
      
    }
  }
  else{
    $(object).previous('.method').className = 'method checked';
    var elements = li_element.ancestors();
    
    if(elements != 'undefined'){
      for( var i=0; i<elements.size(); i++ ){
        var element = elements[i];
        
        if(element.tagName == 'UL' && element.previous() != null){
          element.previous().down('.check_boxes').checked = true;
          element.previous().down('.method').className = 'method checked';
        }
        
      }
    }
    
  }
}




