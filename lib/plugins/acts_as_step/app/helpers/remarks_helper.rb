module RemarksHelper
  
  def display_remarks_list(remarks_owner)
    remarks = remarks_owner.remarks
    html = content_tag :h2, "Commentaires"
    html << '<div id="remarks">'
    unless remarks.empty?
      html << render(:partial => 'remarks/remark', :collection => remarks, :locals => { :remarks_owner => remarks_owner  })
    else
      html << content_tag(:p, "Aucun commentaire n'a été trouvé")
    end
    html << '</div>'
  end
  
  def display_remark_add_button(remarks_owner)
    link_to_function "Ajouter un commentaire" do |page|
      page.insert_html :bottom, :remarks, :partial => 'remarks/remark',
                                          :object => Remark.new,
                                          :locals => { :remarks_owner => remarks_owner }
      remark = page['remarks'].select('.remark').last
      remark.visual_effect :highlight
      #remark.expandable_textarea 
      # TODO create or found a javascript tools to implement auto growing textarea !
      # => http://www.unwrongest.com/projects/expandable-textarea-facebook-style-using-prototype/  I try it but it sucks a bit
      # => http://devkick.com/components/jquery/auto-growing-textarea/ seems to be cool, but use JQuery
      # => create a helper like "insert_html" in ActionView::Helpers::PrototypeHelper::JavaScriptGenerator::GeneratorMethods 
      #    to initialize auto-growing textarea called "expandable_textarea" or "autogrow"
    end
  end
  
end
