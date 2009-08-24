function display_time() {
  var now, dayname, day, monthname, year, hours, minutes, seconds, timeout;
  
  now     = new Date();
  dayname = dayNames[now.getDay()]
  day     = ( now.getDate() < 10 ? "0" : "" ) + now.getDate()
  month   = monthNames[now.getMonth()]
  year    = now.getFullYear()
  hours   = ( now.getHours() < 10 ? "0" : "" ) + now.getHours()
  minutes = ( now.getMinutes() < 10 ? "0" : "" ) + now.getMinutes()
  seconds = ( now.getSeconds() < 10 ? "0" : "" ) + now.getSeconds()
  
  timeout = ( 60 - parseInt(seconds) ) * 1000
  
  $('banner_date').update(dayname + " " + day + " " + month + " " + year)
  $('banner_time').update(hours + ":" + minutes)
  
  window.setTimeout("display_time()", timeout);
}
