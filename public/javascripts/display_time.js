function display_time() {
  var now, dayname, monthname, seconds, minutes, day, hours;

  now = new Date();

switch(now.getDay()){
  case 0: dayname = dayNames[0]; break;
  case 1: dayname = dayNames[1]; break;
  case 2: dayname = dayNames[2]; break;
  case 3: dayname = dayNames[3]; break;
  case 4: dayname = dayNames[4]; break;
  case 5: dayname = dayNames[5]; break;
  case 6: dayname = dayNames[6]; break;
}

switch(now.getMonth()){
  case 0: monthname = monthNames[0]; break;
  case 1: monthname = monthNames[1]; break;
  case 2: monthname = monthNames[2]; break;
  case 3: monthname = monthNames[3]; break;
  case 4: monthname = monthNames[4]; break;
  case 5: monthname = monthNames[5]; break;
  case 6: monthname = monthNames[6]; break;
  case 7: monthname = monthNames[7]; break;
  case 8: monthname = monthNames[8]; break;
  case 9: monthname = monthNames[9]; break;
  case 10: monthname = monthNames[10]; break;
  case 11: monthname = monthNames[11]; break;
}

if(now.getSeconds()<10){
  seconds = "0"+now.getSeconds();
}
else
  seconds = now.getSeconds();

if(now.getMinutes()<10){
  minutes = "0"+now.getMinutes();
}
else
  minutes = now.getMinutes();
  
if(now.getHours()<10){
  hours = "0"+now.getHours();
}
else
  hours = now.getHours();

if(now.getDate()<10){
  day = "0"+now.getDate();
}
else
  day = now.getDate();

  document.getElementById('banner_datetime').innerHTML = "<p>Nous sommes le "+dayname+" "+day+" "+monthname+" "+now.getFullYear()+", il est "+hours+":"+minutes+":"+seconds+"</p>"; 
  
  window.setTimeout("display_time()", 1000);
}
