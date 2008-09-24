// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
if (window.addEventListener)
    {
        window.addEventListener('load', initEventListeners, false);
    }
    else if (document.addEventListener)
        {
            document.addEventListener('load', initEventListeners, false);
        }
        
        function initEventListeners()
        {
            secondary_menu_toggle_button = document.getElementById('secondary_menu_toggle_button');
            
            secondary_menu_toggle_button.addEventListener("click", function(){toggle_secondary_menu(secondary_menu_toggle_button)}, false);
            click_next(0);
        }
        
        function toggle_secondary_menu(item)
        {
            position_hidden = "-210px";
            position_shown = "6px";
            width_shown = "200px";
            width_hidden = "0px";
            class_shown = "shown_secondary_menu";
            class_hidden = "hidden_secondary_menu";
            text_shown = "Cacher le menu";
            text_hidden = "Afficher le menu";
            
            if (item.className == class_shown)
                {
                    document.body.style.overflowX = 'hidden';
                    new Effect.Morph(item.parentNode, {
                        style: {
                            marginRight: position_hidden
                        },
                        duration: 1.5,
                        afterFinish: function(){
                            item.className = class_hidden;
                            document.getElementById("status_text_secondary_menu").innerHTML = text_hidden;
                        }
                    });
                }
                else if (item.className == class_hidden)
                    {
                        document.body.style.overflowX = 'none';
                        item.parentNode.style.width = width_shown;
                        new Effect.Morph(item.parentNode, {
                            style: {
                                marginRight: position_shown
                            },
                            duration: 0.8,
                            afterFinish: function(){
                                item.className = class_shown;
                                document.getElementById("status_text_secondary_menu").innerHTML = text_shown;
                            }
                        });
                    }
                }
                
                function show_memorandum(element_or_position, value) {
                    
                    if (value == 0) {
                        
                        position = element_or_position.lastChild.id.lastIndexOf("_");
                        id = element_or_position.lastChild.id.substr(position + 1);
                    }
                    
                    else {
                        memorandum = document.getElementsByClassName('position_'+element_or_position)[0]
                        position = memorandum.id.lastIndexOf("_");
                        id = memorandum.id.substr(position + 1);
                    }
                    
                    document.location = "/received_memorandums/"+id
                }
                
                function next_memorandum(element, memorandum_number) {
                    
                    if (memorandum_number != 0 && memorandum_number != 1) {
                        
                        place = element.className.lastIndexOf("_");
                        position = element.className.substr(place + 1);
                        
                        document.getElementsByClassName('number')[0].innerHTML = " "+(parseInt(position))+" " ;
                        
                        if ((position - 1) == 0 ) {
                            document.getElementById('previous').className = 'previous_memorandum_'+parseInt(memorandum_number);
                            new Effect.Fade(document.getElementsByClassName('position_'+memorandum_number)[0], {duration: 0.3});
                            
                        }
                        else {
                            document.getElementById('previous').className = 'previous_memorandum_'+parseInt(position - 1);
                            new Effect.Fade(document.getElementsByClassName('position_'+(parseInt(position) -1))[0], {duration: 0.3});
                        }
                        
                        if (position < memorandum_number) {
                            
                            document.getElementById('next').className = 'next_memorandum_'+(parseInt(position) + 1);
                        }
                        else {
                            document.getElementById('next').className = 'next_memorandum_1';
                        }
                        document.getElementById('text_under_banner').setAttribute('onclick', 'show_memorandum('+parseInt(position)+', 1)')
                        new Effect.Appear(document.getElementsByClassName('position_'+position)[0], {duration: 2});
                    }
                }
                
                function previous_memorandum(element, memorandum_number) {
                    
                    if (memorandum_number != 0 && memorandum_number != 1) {
                        
                        place = element.className.lastIndexOf("_");
                        position = element.className.substr(place + 1);
                        
                        document.getElementsByClassName('number')[0].innerHTML = " "+parseInt(position)+" " ;
                        
                        if ((parseInt(position) -1) == 0) {
                            document.getElementById('previous').className = 'previous_memorandum_'+(parseInt(memorandum_number));
                        }
                        else {
                            document.getElementById('previous').className = 'previous_memorandum_'+(parseInt(position) -1);
                        }
                        
                        if (parseInt(position) != memorandum_number) {
                            document.getElementById('next').className = 'next_memorandum_'+(parseInt(position) +1);
                            new Effect.Fade(document.getElementsByClassName('position_'+(parseInt(position) +1))[0], {duration: 0.3});
                        }
                        else {
                            document.getElementById('next').className = 'next_memorandum_1';
                            new Effect.Fade(document.getElementsByClassName('position_1')[0], {duration: 0.3});
                        }
                        document.getElementById('text_under_banner').setAttribute('onclick', 'show_memorandum('+parseInt(position)+', 1)')
                        new Effect.Appear(document.getElementsByClassName('position_'+position)[0], {duration: 2});
                    }
                }
                
                function click_next(value) {
                    if (document.getElementsByClassName('number')[1] != null) {
                        total_memorandum = document.getElementsByClassName('number')[1].innerHTML;
                        
                        if ( total_memorandum != 0 && total_memorandum != 1 ) {
                            if (value == 0) {
                                setTimeout('click_next('+1+');', 15000);
                            }
                            else {
                                document.getElementById('next').click();
                                setTimeout('click_next('+1+');', 15000);
                            }
                        }
                    }
                }
                
                