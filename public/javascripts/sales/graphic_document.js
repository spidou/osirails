var versionOptions

function addOrChangeVersion(action,versionId) {
  if(action == "add"){	  
    document.getElementById("add_version_div").style.display = 'block'
    document.getElementById("change_version_div").style.display = 'none'
    
    versionOptions = $('graphic_document_current_version_id').childElements();
    for(i=0; i<versionOptions.length; i++){
      if(versionOptions[i].value == versionId){
        document.getElementById("graphic_document_current_version_id").selectedIndex = i
      }
	  }
  }
  else if(action == "change"){
    document.getElementById("change_version_div").style.display = 'block'
    document.getElementById("add_version_div").style.display = 'none'
    
    document.getElementById("graphic_document_graphic_item_version_attributes_image").value = ""
    document.getElementById("graphic_document_graphic_item_version_attributes_source").value = ""
  }
}
