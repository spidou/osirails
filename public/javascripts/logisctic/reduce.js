function reduce(parent){
    position = parent.id.lastIndexOf("_");
    id = parent.id.substr(position + 1);
    
    elements = document.getElementsByClassName(parent.id);

        for (i = 0; i < elements.length; i++)
            {
                elements[i].style.display='none';
            }
  
        document.getElementById('commodity_category_'+id+'_develop').style.display='inline';
        document.getElementById('commodity_category_'+id+'_reduce').style.display='none';
        
        
    }