var versionOptions

function addOrChangeVersion(action,versionId) {
  if(action == "add"){	  
    document.getElementById("new_image_paragraph").style.display = 'block'
    document.getElementById("new_source_paragraph").style.display = 'block'
    document.getElementById("change_version_paragraph").style.display = 'none'
    
    versionOptions = $('mockup_current_version_id').childElements();
    for(i=0; i<versionOptions.length; i++){
      if(versionOptions[i].value == versionId){
        document.getElementById("mockup_current_version_id").selectedIndex = i
      }
	  }
  }
  else if(action == "change"){
    document.getElementById("change_version_paragraph").style.display = 'block'
    document.getElementById("new_image_paragraph").style.display = 'none'
    document.getElementById("new_source_paragraph").style.display = 'none'
    
    document.getElementById("mockup_graphic_item_version_attributes_image").value = ""
    document.getElementById("mockup_graphic_item_version_attributes_source").value = ""
  }
}
