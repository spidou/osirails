/* This method permit to return selected option value for a select */
function selectedValue(select) {
    return select.options[select.selectedIndex].value;  
}

function disableUnitMeasure() {
  select = document.getElementById('commodity_category_commodity_category_id');

  value = selectedValue(select);
  
  if (value == "" ) {
  document.getElementById('commodity_category_unit_measure_id').disabled = true;
  }
  else {
  document.getElementById('commodity_category_unit_measure_id').disabled = false;
  }
}
