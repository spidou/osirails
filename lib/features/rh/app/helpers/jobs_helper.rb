module JobsHelper
  def query_thead_tr_in_job(content)
    query_thead_tr_with_context_menu(content, toggle_selectable_items_link(image_tag("confirm_16x16.png"), "job"))
  end
  
  def query_tr_in_job(content)
    query_tr_with_context_menu(content, @query_object, "job_tr")
  end
  
  def query_td_for_name_in_job(content)
    content_tag(:td, content, :class => :text) 
  end
  
  def query_td_content_for_name_in_job
    link_to(@query_object.name, job_path(@query_object))
  end
  
  def query_td_for_mission_in_job(content)
    content_tag(:td, content, :class => :text) 
  end
  
  def query_td_for_activity_in_job(content)
    content_tag(:td, content, :class => :text) 
  end
  
  def query_td_for_goal_in_job(content)
    content_tag(:td, content, :class => :text) 
  end
end
