module PasswordPoliciesHelper
  
  def display_radio_for_level(value, level)
    radio_button_tag('level', value, level == value ) 
  end 
  
  def display_text_field_for_validity(validity)
    text_field_tag("validity", validity, :size => 4 , :maxlength => 5)
  end
  
  def display_text_field_for_pattern(pattern)
    text_field_tag( "pattern", pattern, :size => 40 )
  end
  
  def display_level(level)
    titles = { "l0" => "Aucune sécurité",
               "l1" => "Premier niveau",
               "l2" => "Second niveau",
               "l3" => "Troisième niveau" }
   
    descriptions = { "l0" => "Les utilisateurs pourront choisir un mot de passe sans aucune resctriction",
                     "l1" => "Les utilisateurs devront utiliser un mot de passe comportant entre 6 et 40 caractères et devant comporter des chiffres ou des lettres",
                     "l2" => "Les utilisateurs devront utiliser un mot de passe comportant entre 8 et 40 caractères et devant comporter des chiffres et des lettres, et possédant au moins un caractère spécial (ex: &#64;&#126;&#34;&#40;&#58;&#46;&#47;&#63;)",
                     "l3" => "Les utilisateurs devront utiliser un mot de passe comportant entre 8 et 40 caractères et devant comporter des chiffres et des lettres (en majuscule et minuscule), et possédant au moins un caractère spécial (ex: &#64;&#126;&#34;&#40;&#58;&#46;&#47;&#63;" }
    
    html = ""
    
    if is_form_view?
      html << "<ul>"
      for level_name, title in titles
        html << "<li>"
        html << display_radio_for_level(level_name, level)
        html << label_tag(level_name, title, :title => descriptions[level_name])
        html << "</li>"
      end
      html << "</ul>"
    else
      html << strong(titles[level]) + " [#{descriptions[level]}]"
    end
  end
  
  def display_validity(validity)
    if is_form_view?
      display_text_field_for_validity(validity)
    else
      strong(validity)
    end
  end
  
  def display_pattern(pattern)
    html = ""
    
    if is_form_view?
      html << "<p id=\"pattern_field\""
      html << display_text_field_for_pattern(pattern)
      html << " <span id=\"pattern_help_link\">"
      html << link_to_function( image_tag("help_icon_16x16.png", :alt => "Aide", :title => "Aide"), "Effect.toggle('pattern_help', 'slide')" )
      html << "</span></p>"
    else
      #html << text_field_tag('pattern', 'pattern', :value => pattern, :size => 40, :disabled => 'disabled')
      html << strong(pattern)
    end
  end
  
end
