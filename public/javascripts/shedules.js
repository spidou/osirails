//script  TIME------------------------------------------------------------------------------------------------------------------------------------------
function time (elemnt)
{
	if (isFinite(elemnt.value) == 0 )
	{
		alert ("vous devez entrer des heures entre 0 et 23");
		document.getElementById(elemnt.tabIndex).value ="";

	}
	else
	{
	  if ((elemnt.tabIndex % 2 == 1)&&( elemnt.value > 23  || elemnt.value < 0)) 
	  {
	    alert ("vous devez entrer des heures entre 0 et 23");
		  document.getElementById(elemnt.tabIndex).value =""; 
		  
		}
	  else if ((elemnt.tabIndex % 2 == 0)&&( elemnt.value > 59  || elemnt.value < 0))
	  {
	    alert ("vous devez entrer des minutes entre 0 et 59");
		  document.getElementById(elemnt.tabIndex).value =""; 
	  }
	  else if ( elemnt.tabIndex == 1)
	  {
	    var next = elemnt.tabIndex +1 ;
	    if ( elemnt.value>1 && elemnt.value<=9)
	    {
	      document.getElementById(next).focus();
	    }
	  }
  	else if ( elemnt.value.length == elemnt.maxLength  ) 
  	{
  		var next = elemnt.tabIndex +1 ;
  		if (  next <= 8 )
  		{
  		  document.getElementById(next).focus();
  		}
  	}
  }	
} 
//---------------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------------
function modify_schedule()
{ 
  p_start = 0;
  p_end = 0;
  day = "";
  p_start = document.getElementById('period_0_day').selectedIndex + 1;
  p_end	= document.getElementById('period_1_day').selectedIndex + 1;
  period = [];
  retour="";
 
  if( p_start!=p_end )
  { 
    if(p_start>p_end)
    { 
      for (i = 0; i < 7; i ++)
      {
        if (i+1<= p_end || i+1>=p_start)
        {
          period[i] = i + 1;
        }
        else
        {
          period[i] = 0;
        }
      }
    }
    else
    {
      for (inc = 0; inc < p_end; inc ++)
      {
        if (inc+1>=p_start)
        {
          period[inc] = inc + 1;
        }
        else
        {
          period[inc] = 0;
        }  
      }
    }
  }
  else
  {
    period[0] = p_start;
  }


  for(i = 0; i < period.length ; i ++)
  {

    if(period[i]!=0)
    {
      switch(period[i])
      {
        case 1: day = "Lundi";
          break;
        case 2: day = "Mardi";
          break;
        case 3: day = "Mercredi";
          break;
        case 4: day = "Jeudi";
          break;
        case 5: day = "Vendredi";
          break;
        case 6: day = "Samedi";
          break;
        case 7: day = "Dimanche";
          break;
      }             
      retour += "<td name=" + day + ">" + day + "</td>";
      retour += "<td name=" + day + ">" + document.getElementById(1).value +" H "+  document.getElementById(2).value + "</td>";
      retour += "<td name=" + day + ">" + document.getElementById(3).value +" H "+  document.getElementById(4).value + "</td>";
      retour += "<td name=" + day + ">" + document.getElementById(5).value +" H "+  document.getElementById(6).value + "</td>";
      retour += "<td name=" + day + ">" + document.getElementById(7).value +" H "+  document.getElementById(8).value + "</td>";
      document.getElementById("t_"+day).innerHTML = retour ;
      document.getElementById("schedules_" + period[i]).value = document.getElementById(1).value + " H " +
                             document.getElementById(2).value + "|" + document.getElementById(3).value + " H " + 
                             document.getElementById(4).value + "|" + document.getElementById(5).value + " H " +
                             document.getElementById(6).value + "|" + document.getElementById(7).value + " H " +
                             document.getElementById(8).value
      retour = "";
    }
  } 
}
//---------------------------------------------------------------------------------------------------------------------------

