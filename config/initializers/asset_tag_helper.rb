require 'action_view/helpers/tag_helper'
#raise 'test'
module ActionView
  module Helpers
    module AssetTagHelper
      
      # override image_path to take in account the themes 
      def path_to_image(source)  
        compute_public_path(source, "#{$CURRENT_THEME_PATH.rchomp('/')}/images")
      end
      
    end 
  end
end
