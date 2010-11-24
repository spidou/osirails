module JobsHelper
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
