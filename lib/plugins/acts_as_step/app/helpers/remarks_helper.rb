module RemarksHelper
  
  def display_remarks_list(remarks_owner)
    remarks = remarks_owner.remarks
    html = '<div id="remarks">'
    unless remarks.empty?
      html << render(:partial => 'remarks/remark', :collection => remarks, :locals => { :remarks_owner => remarks_owner  })
    else
      html << content_tag(:p, "Aucun commentaire n'a été trouvé")
    end
    html << '</div>'
  end
  
  def display_remark_add_button(remarks_owner, position = :bottom)
    return "" unless Remark.can_add?(current_user) and remarks_owner.class.can_edit?(current_user)
    content_tag(:p, link_to_function("Ajouter un commentaire") do |page|
      page.insert_html position, :remarks, :partial => 'remarks/remark',
                                           :object => Remark.new,
                                           :locals => { :remarks_owner => remarks_owner }
      if position == :bottom
        remark = page['remarks'].select('.remark').last
      elsif position == :top
        remark = page['remarks'].select('.remark').first
      end
      remark.visual_effect :highlight
      page.call 'initialize_autoresize_text_areas'
    end )
  end
  
end
