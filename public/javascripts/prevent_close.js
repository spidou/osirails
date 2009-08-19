// Permits to ask confirmation if the user leave the document
// and if a form has been modified since the opening.
// Use the class "skip_prevent_close" to skip a form

var allTargetedForms
var initialAttributes = new Array();

function initializeAttributes(){
  allTargetedForms = $$('form:not([class~=skip_prevent_close])'); 
  for (i=0; i<allTargetedForms.length; i++) {
    initialAttributes[i] = new Array();
    for(e=0; e<allTargetedForms[i].elements.length; e++){
      if(allTargetedForms[i].elements[e].id != ''){
	      initialAttributes[i][e] = allTargetedForms[i].elements[e].value
	    }
	  }     	  
  }
}

var change = 0;

function preventClose(){

  for (i=0; i<allTargetedForms.length; i++) {
    
    for(e=0; e<allTargetedForms[i].elements.length; e++){
      if(allTargetedForms[i].elements[e].id != ''){
        if (allTargetedForms[i].elements[e].value!=initialAttributes[i][e]){
          change = 1
        }
      }
	  } 	    
  }
  if (change == 1){
    return "Vous avez effectué des modifications non enregistrées.";
  }
}
