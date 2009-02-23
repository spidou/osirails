function confirm_premium()
{
  text = "Etes vous sûr de vouloir ajouter la prime suivante? \n\n"
  text += "Montant : " + document.getElementById('premium_amount').value + "€ \n";
  text += "Commentaire : " + document.getElementById('premium_remark').value + "\n";
  text += "Date : " + document.getElementById('premium_date_3i').value + "/";
  text += document.getElementById('premium_date_2i').value + "/";
  text += document.getElementById('premium_date_1i').value + "\n\n";
  text += "Attention cette action est irreversible !"
  
  return confirm(text);
}
