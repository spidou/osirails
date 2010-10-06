module JobsHelper
  def query_thead_tr_in_job_index(content)
    query_thead_tr_with_context_menu(content, toggle_selectable_items_link(image_tag("confirm_16x16.png"), "job"))
  end
  
  def query_tr_in_job_index(content)
    query_tr_with_context_menu(content, @query_object, "job_tr")
  end
end
