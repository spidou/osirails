var now, timeout;

function initialize_time(){
  now = new Date(rubyTime);
  timeout = ( 60 - parseInt(now.getSeconds())) * 1000;
}

function display_time() {
  var dayname, day, monthname, year, hours, minutes;    
  
  day     = ( now.getDate() < 10 ? "0" : "" ) + now.getDate();
  dayname = rubyDayNames[now.getDay()];
  monthname   = rubyMonthNames[now.getMonth()];
  year    = now.getFullYear();
  hours   = ( now.getHours() < 10 ? "0" : "" ) + now.getHours();
  minutes = ( now.getMinutes() < 10 ? "0" : "" ) + now.getMinutes();
  
  $('banner_date').update(dayname + " " + day + " " + monthname + " " + year);
  $('banner_time').update(hours + ":" + minutes);
  
  now.setMinutes(now.getMinutes()+1);
  window.setTimeout("display_time()", timeout);  
  timeout = 60000;
}


