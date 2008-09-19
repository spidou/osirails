function action_choose(select)
      { 
        switch( select.options[select.selectedIndex].value.split(",")[1] )
        {
          case "date" :
            document.getElementById('actions').innerHTML = ""
            document.getElementById('actions').innerHTML = "<select>" +
                                                            "<option value=\"egal &agrave;\"> egal &agrave</option>"+
                                                            "<option value=\"plus grand que\"> plus grand que</option>"+
                                                            "<option value=\"plus petit que\"> plus petit que</option>"+
                                                          "</select>";
            inputType(select);
            break;                                                
          case "int" :
            document.getElementById('actions').innerHTML = ""
            document.getElementById('actions').innerHTML = "<select>" +
                                                            "<option value=\"egal &agrave;\"> egal &agrave</option>"+
                                                            "<option value=\"plus grand que\"> plus grand que</option>"+
                                                            "<option value=\"plus petit que\"> plus petit que</option>"+
                                                          "</select>";
            inputType(select);
            break;
          case "string" :
            document.getElementById('actions').innerHTML = ""
            document.getElementById('actions').innerHTML = "<select>" +
                                                            "<option value=\"contient\"> contient</option>"+
                                                            "<option value=\"ne contient pas\">ne contient pas</option>"+
                                                          "</select>";                                                  
            inputType(select);
            break;
        } 
      }
      
      function inputType(select)
      {
        switch( select.options[select.selectedIndex].value.split(",")[1] )
        {
          case "string" :
            document.getElementById('input_type').innerHTML = "<input type=\"text\" />";                                             
            break;                                                
          case "int" :
            document.getElementById('input_type').innerHTML = "<input type=\"text\" id=\"number_input\" onkeyup=\"isNumber(this);\" />";
            break;
          case "date" :
            document.getElementById('input_type').innerHTML = "<select>" +
                                                            "<option selected=\"true\"></option>"+
                                                            "<option value=\"1\"> 1</option>"+
                                                            "<option value=\"2\">2</option>"+
                                                          "</select>"+" "+
                                                           "<select>" +
                                                            "<option selected=\"true\"></option>"+
                                                            "<option value=\"contient\"> Janvier</option>"+
                                                            "<option value=\"ne contient pas\">D&eacute;cembre</option>"+
                                                          "</select>"+" "+ 
                                                           "<select>" +
                                                            "<option selected=\"true\"></option>"+
                                                            "<option value=\"contient\">2000</option>"+
                                                            "<option value=\"ne contient pas\">2008</option>"+
                                                          "</select>";                                                                                                                                               
            break;
        } 
      }
      
      function isNumber(elemnt)
      {
        if (isFinite(elemnt.value) == 0 )
      	{
      		alert ("vous devez entrer des chiffres");
      		document.getElementById(elemnt.id).value ="";

      	}
      }