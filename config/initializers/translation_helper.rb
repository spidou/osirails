# thanks to apidock.com (http://apidock.com/rails/ActionView/Helpers/TranslationHelper/localize#897-nil-Argument-Raises-An-I18n-ArgumentError)
module ActionView
  module Helpers
    module TranslationHelper
      def localize(*args)
        I18n.localize(*args) unless args.first.nil?
      end
      alias l localize
    end
  end
end
