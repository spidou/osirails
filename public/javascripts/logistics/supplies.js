/* This method permit to return selected option value for a select */

var supply_class;

function group_unfold(element){
  tr            = element.up('tr')
  supply_class  = element.up('table').className
  
  id = tr.id.substr( tr.id.lastIndexOf("_") + 1 )
  
  $$('.' + tr.id).each(function(element){
    element.show();
    
    if (element.className.include("group")) {
      element.down('.unfold_button').hide()
      element.down('.fold_button').show()
    }
  })
  
  tr.down('.unfold_button').hide()
  tr.down('.fold_button').show()
}

function group_fold(element){
  tr            = element.up('tr')
  supply_class  = element.up('table').className
  
  id = tr.id.substr( tr.id.lastIndexOf("_") + 1 )
  
  $$('.' + tr.id).each(function(element){
    element.hide();
  })
  
  tr.down('.unfold_button').show()
  tr.down('.fold_button').hide()
}

function update_status_for_supply_categories_supply_size(element) {
  p = element.up('p.supply_categories_supply_size')
  
  if (element.value > 0) {
    p.removeClassName("should_destroy")
    p.addClassName("selected")
  } else if (p.down('.supply_categories_supply_size_id').value > 0) {
    p.removeClassName("selected")
    p.addClassName("should_destroy")
  } else {
    p.removeClassName("selected")
  }
}
