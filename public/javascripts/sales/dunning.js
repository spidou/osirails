function toggle_blind(element)
{
  if($(element).visible()){
    $(element).blindUp( {duration:1, fps:24});
  }
  else{
    $(element).blindDown({duration:1, fps:24});
  }
}
