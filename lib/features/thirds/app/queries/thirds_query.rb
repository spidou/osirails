module ThirdsQuery
  def query_td_for_name_in_third(content)
    content_tag(:td, link_to(content, @query_object), :class => :text)
  end
  
  def query_td_for_legal_form_name_in_third(content)
    content_tag(:td, content, :class => :text)
  end
  
  def query_td_for_activity_sector_reference_get_activity_sector_name_in_third(content)
    content_tag(:td, content, :class => :text)
  end
end
