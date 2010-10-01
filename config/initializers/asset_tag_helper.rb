require 'action_view/helpers/tag_helper'
#raise 'test'
module ActionView
  module Helpers
    module AssetTagHelper
      # override image_path to take in account the themes 
      def path_to_image_with_theme_support(source)
        source = "/#{$CURRENT_THEME_PATH.rchomp('/')}/images/#{source}" unless source.match(/:\/\/|^\//)
        path_to_image_without_theme_support(source)
      end
      
      alias_method_chain :path_to_image, :theme_support
    end 
  end
end
