class HomeController < ApplicationController
  
  def index
    @widgets = Osirails::WidgetManager.widgets
    @widgets = @widgets.each{ |k,v| v[:content] = render(:file => v[:path]); erase_results }.reject{ |k,v| v[:content].blank? } # clean widgets by removing empty ones (no contents)
    i = 0
    @widgets.each do |k, v|
      if widget = current_user.widgets.find_by_name(k)
        @widgets[k][:column] = widget.col
        @widgets[k][:position] = widget.position
      else
        @widgets[k][:column] = (i%3)+1 # 3 columns #TODO make it configurable
        @widgets[k][:position] = 99 #TODO find a way to define a default position, according to other widgets which already have a position, and which not
      end
      i = i + 1
    end
  end
  
  def widgets
    respond_to do |format|
      format.js do
        @widget = current_user.widgets.find_by_name(params[:widget]) || current_user.widgets.create(:name => params[:widget])
        @widget.update_attribute(:col, params[:column])
        @widget.insert_at(params[:position])
        render :nothing => true
      end
    end
  end
  
end
