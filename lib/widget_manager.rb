module Osirails
  class WidgetManager
    @@widget_paths = []
    @@widgets = nil
    
    class << self
      def widget_paths
        @@widget_paths
      end
      
      def widget_paths=(paths)
        @@widget_paths = paths
      end
      
      def prepend_widget_path(path)
        @@widget_paths.unshift(*path)
        ActionController::Base.prepend_view_path(path)
      end
      
      def append_widget_path(path)
        @@widget_paths.push(*path)
        ActionController::Base.append_view_path(path)
      end
      
      def widgets
        return @@widgets unless @@widgets.nil?
        @@widgets = {}
        
        paths = @@widget_paths.collect{ |path| Dir.glob(path + '/[^_]*.html.erb') }.flatten.reverse # get only templates, not partials
        
        paths.each_with_index do |path, index|
          @@widgets[File.basename(path, ".html.erb")] = { :path => path }
        end
        
        @@widgets
      end
    end
    
  end
end
