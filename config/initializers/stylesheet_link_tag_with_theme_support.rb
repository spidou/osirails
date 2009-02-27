module ActionView
  module Helpers #:nodoc:
    module AssetTagHelper
      def stylesheet_link_tag_with_theme_support(*sources)
        stylesheet_link_tag sources.collect{ |s| s.insert(0, $CURRENT_THEME_PATH + "/stylesheets/") }
      end
    end
  end
end