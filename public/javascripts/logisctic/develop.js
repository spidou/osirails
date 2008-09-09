function develop(parent){
    position = parent.id.lastIndexOf("_");
    id = parent.id.substr(position + 1);
    
    elements = document.getElementsByClassName(parent.id);
    
    for (i = 0; i < elements.length; i++)
        {            
            elements[i].style.display='table-row';      
        }
        
        for (i = 0; i < elements.length; i++) {
            
            elements_position = elements[i].id.lastIndexOf("_");
            elements_id = elements[i].id.substr(position + 1);
            
            if (elements_id != "") {
                actual_status = document.getElementById('commodity_category_'+elements_id+'_develop').style.display;
                elements_child = document.getElementsByClassName('commodity_category_'+elements_id)
                if (actual_status != "none") {
                    for (j = 0; j < elements_child.length; j++) {
                        elements_child[j].style.display='none';
                    }
                    
                }
            }
            
        }
        
        document.getElementById('commodity_category_'+id+'_develop').style.display='none';
        document.getElementById('commodity_category_'+id+'_reduce').style.display='inline';
    }
    
    