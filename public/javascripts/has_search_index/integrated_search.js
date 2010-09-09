function move_selected_options(from, to)
{
  while ($(from).selectedIndex != -1)
  {
    var option = $(from).options[$(from).selectedIndex]
    option.selected = false
    $(to).insert(option.remove())
  } 
}


function move_option_up(select)
{
  if($(select) == null || $(select).selectedIndex <= 0)  return null
  
  selected_indexes(select).reverse().each(function(index){
    option = $(select).options[index] 
    option.previous().insert( {before: option} )
  })
}

function move_option_down(select)
{
  if($(select) == null || $(select).selectedIndex == -1 || $(select).selectedIndex == $(select).options.length - 1 )  return null
  
  selected_indexes(select).each(function(index){
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

function selected_indexes(select)
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

function valid_select_options(ids)
{
  suffixes = ids.split(' ')
  suffixes.each(function(suffix){
    if($('selected_' + suffix) != null){
      selectAll('selected_' + suffix)
    }
  })
}

function submit_form_for(action)
{
  valid_select_options('group columns')
  $('query_form').setAttribute('action', '/queries/' + action)
  $('query_form').submit()
}

// Method used to toggle group of rows
//
function toggle_group(link)
{
  link.up('TR').siblings().each(function(group){
    group.toggle();
  })
}

function toggle_fieldset(page_name, legend)
{
  cookie_name      = page_name + (legend.up('FIELDSET').className == 'options_field' ? '_options' : '_criteria')
  legend.className = (legend.next().visible() ? 'collapsed' : 'not-collapsed')
  exp_date         = new Date( 2038 , 1, 1 ); // the year is set to 2038 to simule never expire behavior FIXME
  setCookie(cookie_name, !legend.next().visible(), exp_date, '/')
  
  Effect.toggle(legend.next(), 'blind', {duration:0.2});
  
}

function toggle_integrated_form(page_name, link)
{
  main_form_visibility = link.up().previous('.integrated_search_form').visible()
  
  link.className = (main_form_visibility ? 'toggle_show' : 'toggle_hide')
  exp_date       = new Date( 2038 , 1, 1 ); // the year is set to 2038 to simule never expire behavior FIXME
  setCookie(page_name + '_form', !main_form_visibility, exp_date, '/')
  
  Effect.toggle(link.up().previous('.integrated_search_form'), 'blind', {duration:0.3})
}

//-------------------------------------------- dynamique attribute chooser methods------------------------------ 
function showSubMenu(li)
{
  li.siblings('LI').each(function(li){ hideSubMenu(li) })
  ul = li.down('UL')
  if( ul != null){
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
      showSubMenu(li)
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
  // forget the old selectipon
  var li = element.up('.criterion').down('.selected')
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
