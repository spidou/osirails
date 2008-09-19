/* This method permit to return selected option value for a select */
function selectedValue(select) {
    if (select.options[select.selectedIndex].value != -1) {
    select.options[select.selectedIndex].disabled=true;
    document.getElementById('service_option_0').disabled=true;
    }
    return select.options[select.selectedIndex].value;
    
}

/* This method permit to return selected option name for a select */
function selectedTitle(select) {
    return select.options[select.selectedIndex].title;
}

/* This method permit to addServiceCell */
function addServiceCell(select) {
    service_id = selectedValue(select);
    
    if (service_id != -1) {
        
        service_name = selectedTitle(select);
        
        if (document.getElementsByClassName('service_'+service_id).length == 0) {
            
            row = document.createElement("tr");
            
            service_name_cell = document.createElement("td");
            service_recursive_cell = document.createElement("td");
            service_remove_cell = document.createElement("td");
            img = document.createElement("img");
            
            checkbox_id = document.createElement("input");
            checkbox = document.createElement("input");
            
            row.className = "services_rows service_"+service_id;
            
            service_name_cell.innerHTML = service_name;
            
            img.setAttribute("onclick", "removeServiceCell(this.ancestors()[1])");
            img.setAttribute("src", "/images/reduce_button_16x16.png");
            img.setAttribute("alt", "Enlever");
            img.setAttribute("title", "Enlever");
            
            checkbox_id.type = "checkbox"
            checkbox_id.value = service_id;
            checkbox_id.name = "memorandums_services[service_id][]";
            checkbox_id.style.display="none";
            checkbox_id.setAttribute("checked","checked");
            
            checkbox.type = "checkbox"
            checkbox.value = service_id;
            checkbox.name = "memorandums_services[recursive][]";

            if (service_id == 0) {
            checkbox.disabled=true;
            recursiveModeOn(select.options[select.selectedIndex].value);
            }
            else {
                        checkbox.setAttribute("onclick", "recursiveModeOn("+service_id+")");
            }
            service_recursive_cell.appendChild(checkbox_id);
            service_recursive_cell.appendChild(checkbox);
            service_remove_cell.appendChild(img);
            
            row.appendChild(service_name_cell);
            row.appendChild(service_recursive_cell);
            row.appendChild(service_remove_cell);
            document.getElementById('services_list').appendChild(row);
            
            document.getElementById('services').style.display='block';
                
            }
            
        }
    }


/* This method permit to removeServiceCell*/
function removeServiceCell(parent) {
    
    position = parent.className.lastIndexOf("_");
    parent_id = parent.className.substr(position + 1);
    
    document.getElementById('service_option_'+parent_id).disabled=false;
    
    parent.remove();
    
    if (document.getElementsByClassName('services_rows').length == 0) {
        document.getElementById('services').style.display='none';
        document.getElementById('service_option_0').disabled=false;
    }
    
    if (parent_id == 0) {
    element = document.getElementById('service_option_0');
    brother = element.nextSibling;
    brother.disabled=false
    
    position = brother.id.lastIndexOf("_");
    brother_id = brother.id.substr(position +1);    
    }
    else {
    id = parent_id
    }
    
    children = document.getElementsByClassName('parent_service_'+id);
    
    for (i=0; i < children.length ; i++) {
        children[i].disabled=false;
    }
       
    
}

/* This method permit to recursiveModeOn */
function recursiveModeOn(service_id) {

    if (service_id == 0) {
    element = document.getElementById('service_option_0');
    brother = element.nextSibling;
    brother.disabled=true
    
    position = brother.id.lastIndexOf("_");
    id = brother.id.substr(position +1);
    
    }
    else {
    id = service_id
    }

    children = document.getElementsByClassName('parent_service_'+id);
    for (i=0; i < children.length ; i++) {
        children[i].disabled=true;
    }
    if (service_id != 0) {
    input = document.getElementsByClassName('service_'+id)[0].childNodes[1].childNodes[1];
    input.setAttribute("onclick", "recursiveModeOff("+id+")");
    }
}

/* This method permit to recursiveModeOff */
function recursiveModeOff(id) {
    children = document.getElementsByClassName('parent_service_'+id);
    for (i=0; i < children.length ; i++) {
        children[i].disabled=false;
    }
    input = document.getElementsByClassName('service_'+id)[0].childNodes[1].childNodes[1];
    input.setAttribute("onclick", "recursiveModeOn("+id+")");
}

/* This method permit to keep checkbox checked */
function keepChecked(checkbox) {
alert(checkbox);
    checkbox.setAttribute("checked", "checked");
}
