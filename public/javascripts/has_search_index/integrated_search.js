function moveSelectedOptions(from, to)
{
  while ($(from).selectedIndex != -1)
  {
    var option = $(from).options[$(from).selectedIndex]
    option.selected = false
    $(to).insert(option.remove())
  } 
}


function moveOptionUp(select)
{
  if($(select) == null || $(select).selectedIndex <= 0)  return null
  
  selectedIndexes(select).reverse().each(function(index){
    option = $(select).options[index] 
    option.previous().insert( {before: option} )
  })
}

function moveOptionDown(select)
{
  if($(select) == null || $(select).selectedIndex == -1 || $(select).selectedIndex == $(select).options.length - 1 )  return null
  
  selectedIndexes(select).each(function(index){
    option = $(select).options[index] 
    option.next().insert( {after: option} )
  })
}

function selectAll(select)
{
  $(select).childElements().each(function(child){
    child.selected = true;
  })
}

function unSelectAll(select)
{
  $(select).childElements().each(function(child){
    child.selected = false;
  })
}

function selectedIndexes(select)
{
  indexes = new Array
  
  while ($(select).selectedIndex != -1)
  {
    indexes.push($(select).selectedIndex)
    $(select).options[$(select).selectedIndex].selected = false
  }
  
  indexes.each(function(index){
    $(select).options[index].selected = true;
  })
  
  return indexes.reverse() // keep selection order
}

function validSelectOptions(ids)
{
  suffixes = ids.split(' ')
  suffixes.each(function(suffix){
    if($('selected_' + suffix) != null){
      selectAll('selected_' + suffix)
    }
  })
}

function isNumber(element)
{
  value = element.value.split(" ");
  for (var i = 0; i < value.length; i++){ 
    if (isFinite(value[i]) == 0 && value[i] != ""){
		  alert ("Vous devez entrer un nombre");
		  $(element.id).value ="";
	  }
	}
}

function submitFormFor(action)
{
  validSelectOptions('group columns')
  $('query_form').setAttribute('action', '/queries/' + action)
  $('query_form').submit()
}

// Method used to toggle group of rows
//
function toggleGroup(link)
{
  link.className = (link.className == 'collapsed' ? 'not-collapsed' : 'collapsed')
  link.up('TR').siblings().each(function(group){
    group.toggle();
  })
}

function toggleCriteriaFieldset(page_name, legend)
{
  toggleFieldset(page_name, 'criteria', legend)
}

function toggleOptionsFieldset(page_name, legend)
{
  toggleFieldset(page_name, 'options', legend)
}

function toggleFieldset(page_name, category, legend)
{
  cookie_name      = [page_name, category].join('_')
  legend.className = (legend.next().visible() ? 'collapsed' : 'not-collapsed')
  exp_date         = new Date( 2038 , 1, 1 ); // the year is set to 2038 to simule never expire behavior FIXME
  setCookie(cookie_name, !legend.next().visible(), exp_date, '/')
  
  Effect.toggle(legend.next(), 'blind', {duration:0.2});
}

function toggleIntegratedForm(page_name, link)
{
  main_div = link.up('.integrated_search_form_footer')
  main_form_visibility = main_div.previous('.integrated_search_form').visible()
  
  if (main_div.down('.quick_search_inputs') != null) {
    link.toggleClassName('quick_search_visible')
    main_div.down('.quick_search_inputs').toggleClassName('hidden');
  }
  exp_date = new Date( 2038 , 1, 1 ); // the year is set to 2038 to simule never expire behavior FIXME
  setCookie(page_name + '_form_visible', !main_form_visibility, exp_date, '/')
  
  Effect.toggle(main_div.previous('.integrated_search_form'), 'blind', {duration:0.3})
}

//-------------------------------------------- dynamique attribute chooser methods------------------------------ 
function showSubMenu(li, only_selected)
{
  li.siblings('LI').each(function(li){ hideSubMenu(li) })
  ul       = li.down('UL')
  if(ul != null && (only_selected != null ? ul.down('.selected') != null : true) ){
    ul.style.left = li.parentNode.getStyle('width')
    ul.show()
    ul.addClassName('visible_menu')
  }
}

function hideSubMenu(li)
{
  if(li.down('UL') != null)
    hideMenuAndSubMenus(li.down('UL'))
}

function hideMenuAndSubMenus(ul)
{
  while(ul != null){
    ul.hide()
    ul.removeClassName('visible_menu')
    ul = ul.down('.visible_menu')
  }
}

function startObserverToHideOnClick(element)
{
  Event.observe(window, 'mouseup', function(window_event) {
    if(element.visible()){ 
      hideMenuAndSubMenus(element)
    }
  });
}

function showAttributeChooser(element)
{
  ul = element.up().next('UL')
  if(ul != null){
    ul.show()
    startObserverToHideOnClick(ul)
    
    // show the selection
    var li = element.up('.criterion').down('.selected')
    while(li != null){
      showSubMenu(li, only_selected = true)
      li = li.down('.selected')
    }
  }
}

function replaceAttribute(element, content)
{
  span = element.up('.criterion').down('.attribute').down()
  if(span != null){ span.replace(content) }
}

function footPrint(element)
{
  // forget the old selection
  var li = element.up('.attribute_chooser').down('.selected')
  while(li != null) {
    li.removeClassName('selected')
    li = li.down('.selected')
  }
  
  // remember the new selection
  element.up('LI').addClassName('selected')
  var li = element.up('LI')
  while(li != null){
    li.addClassName('selected')
    li = li.up('LI')
  }
}

function insertAttributeChooser(element)
{
  if(element.up('.criterion').down('.attribute').down().className == 'new_criterion'){
    attribute_chooser_content = element.up('.criterion').innerHTML
    element.up('.criteria').down('TABLE').insert({bottom: "<tr class='criterion'>" + attribute_chooser_content + "</tr>"})
  }
}

function insertInputs(element, content)
{
  element.up('.criterion').down('.inputs').innerHTML = content
}

function toggleMultiple(span)
{
  select = span.previous('SELECT')
  if(select.multiple){
    select.multiple = false
    span.removeClassName('multiple')
  }
  else{
    select.multiple = true
    span.addClassName('multiple')
  }
}


function applySelection(select, hidden)
{
  value = new Array
  if(select.multiple){
    selectedIndexes(select).each(function(i){
      value.push(select.options[i].value)
    })
  }
  else{
    value.push(select.options[select.selectedIndex].value)
  }
  hidden.value = value.join(' ')
}

function gather_all_order_options(option, column)
{
  var options = []
  $$(".query_order_options").each(function(element){
    options.push("query[order][]=" + element.value)
  })
  
  return options.join('&')
}

function persist_order_option(option, column)
{
  var hidden = new Element('input', {
    'type' : 'hidden' ,
    'name' : 'query[order][]' ,
    'class': 'query_order_options',
    'id'   : 'query_order_' + column,
    'value': option
   })
  if( $('query_order_' + column) ) $('query_order_' + column).remove()
  if( option.endsWith('asc') || option.endsWith('desc')  ) $('options_hidden_fields').insert(hidden)
}

function persist_paginate_option(option)
{
  if( $('query_per_page') ){
    if(option == 'all'){
      $('query_per_page').removeAttribute('value')
    }else{
      $('query_per_page').value = option
    }
  }
}
