function toggle_blind(link, element)
{
  if($(element).visible()){
    $(element).blindUp( {duration:1, fps:24});
    $(link).update( 'Voir les relances annulées' );
  }
  else{
    $(element).blindDown({duration:1, fps:24});
    $(link).update( 'Cacher les relances annulées' );
  }
}
