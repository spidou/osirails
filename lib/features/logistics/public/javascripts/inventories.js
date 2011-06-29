function update_new_quantity_evolution(element) {
  tr = element.up('tr')
  td = element.up('td')
  stock_quantity = parseInt(tr.down('.stock_quantity').innerHTML)
  new_stock_quantity = element.value
  
  if (isNaN(new_stock_quantity) || isNaN( new_stock_quantity = parseInt(new_stock_quantity) )) {
    td.addClassName('error')
    
    td.removeClassName('increase')
    td.removeClassName('decrease')
    td.removeClassName('stagnancy')
  } else {
    td.removeClassName('error')
    
    if (new_stock_quantity > stock_quantity) {
      td.removeClassName('stagnancy')
      td.removeClassName('decrease')
      td.addClassName('increase')
    } else if (new_stock_quantity < stock_quantity) {
      td.removeClassName('stagnancy')
      td.removeClassName('increase')
      td.addClassName('decrease')
    } else {
      td.removeClassName('increase')
      td.removeClassName('decrease')
      td.addClassName('stagnancy')
    }
  }
}
