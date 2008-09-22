function action_choose(select,line,month)
      { 
      alert(line);
        document.getElementById("blank" + line).disabled=true;
        document.getElementById('add_link').style.display='inline';
        document.getElementById('delete_link'+line).style.display='inline';
        document.getElementById('attribute_name' + line).innerHTML ="of " + select.options[select.selectedIndex].parentNode.label
        
        switch( select.options[select.selectedIndex].value.split(",")[1] )
        {
          case "date" :
            document.getElementById('actions' + line).innerHTML = ""
            document.getElementById('actions' + line).innerHTML = "<select name=\"criteria["+ line+ "][action]\">" +
                                                            "<option value=\"egal &agrave;\"> egal &agrave</option>"+
                                                            "<option value=\"plus grand que\"> plus grand que</option>"+
                                                            "<option value=\"plus petit que\"> plus petit que</option>"+
                                                          "</select>";
            inputType(select,line,month);
            break;                                                
          case "int" :
            document.getElementById('actions' + line).innerHTML = ""
            document.getElementById('actions' + line).innerHTML = "<select name=\"criteria[" + line + "][action]\">" +
                                                            "<option value=\"egal &agrave;\"> egal &agrave</option>"+
                                                            "<option value=\"plus grand que\"> plus grand que</option>"+
                                                            "<option value=\"plus petit que\"> plus petit que</option>"+
                                                          "</select>";
            inputType(select,line,month);
            break;
          case "string" :
            document.getElementById('actions' + line).innerHTML = ""
            document.getElementById('actions' + line).innerHTML = "<select name=\"criteria[" + line + "][action]\">" +
                                                            "<option value=\"contient\"> contient</option>"+
                                                            "<option value=\"ne contient pas\">ne contient pas</option>"+
                                                          "</select>";                                                  
            inputType(select,line,month);
            break;
        } 
      }
      
      function inputType(select,line,month)
      {
        switch( select.options[select.selectedIndex].value.split(",")[1] )
        {
          case "string" :
            document.getElementById('input_type' + line).innerHTML = "<input type=\"text\" name=\"criteria[" + line + "][value]\" />";                                             
            break;                                                
          case "int" :
            document.getElementById('input_type' + line).innerHTML = "<input type=\"text\" name=\"criteria[" + line + "][value]\" id=\"number_input\" onkeyup=\"isNumber(this);\" />";
            break;
          case "date" :
            days = "";
            months = "";
            for(i=1;i<=31;i++)
            {
              days += "<option value=\"" + i + "\"> " + i + "</option>";
            }
            for(i=1;i<=12;i++)
            {
              months += "<option value=\"" +  i + "\">" + month[i] + "</option>";
            } 
            document.getElementById('input_type' + line).innerHTML = "<select onchange=\"disable_blank(this);\" name=\"criteria[" + line + "][date(3i)]\">" +
                                                            "<option disbled=\"true\" selected=\"true\"></option>"+days +
                                                            "</select>"+" "+
                                                           "<select onchange=\"disable_blank(this);\" name=\"criteria[" + line + "][date(2i)]\">" +
                                                            "<option selected=\"true\"></option>"+ months +
                                                           "</select>"+" "+ 
                                                           "<select onchange=\"disable_blank(this);\" name=\"criteria[" + line + "][date(1i)]\">" +
                                                            "<option selected=\"true\"></option>"+
                                                            "<option value=\"2000\">2000</option>"+
                                                            "<option value=\"2008\">2008</option>"+
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
      function disable_blank(select)
      {
       select.options[0].disabled = true; 
      }
      
