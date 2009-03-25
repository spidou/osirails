# Be sure to restart your server when you modify this file.
#
# Permit to add new route from other file than config/routes.rb
# Do not modify this file.

module ActionController
  module Routing
    class RouteSet
      def add_routes
        yield Mapper.new(self)
        install_helpers([ActionController::Base, ActionView::Base], true)
      end
    end
  end
end
