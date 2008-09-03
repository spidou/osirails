function develop(parent){
  position = parent.id.lastIndexOf("_");
  id = parent.id.substr(position + 1);
  
  elements = document.getElementsByClassName(parent.id);
  for (i = 0; i < elements.length; i++)
    {
      elements[i].style.display='table-row';
    }
    
    document.getElementById('commodity_category_'+id+'_develop').style.display='none';
    document.getElementById('commodity_category_'+id+'_reduce').style.display='inline';
  }