// This function permit to refraiche total for categories

function total(parent) {

// Find sub_category's id
var reg = new RegExp("[ _ ]+", "g");
var class_name = parent.className.split(reg);
var sub_category_id = class_name[2];

// Find category's id'
var position = parent.className.lastIndexOf("_");
var category_id = parent.className.substr(position + 1);

// Select All ElementByClassName
var sub_categories = document.getElementsByClassName('sub_commodity_category_'+sub_category_id+'_total');
var categories = document.getElementsByClassName('commodity_category_'+category_id+'_total');

// Initialize totals
var sub_category_total = 0;
var category_total = 0;

// Calcul sub_category_total
for (i = 1; i < sub_categories.length ; i++)
  {
  sub_category_total += parseFloat(sub_categories[i].innerHTML);
  }
  
// Calcul category_total
for (i = 1; i < categories.length ; i ++)
  {
  category_total += parseFloat(categories[i].innerHTML);
  }
  
// Change total  
  sub_categories[0].innerHTML = sub_category_total;
  categories[0].innerHTML = category_total;
}