module ActsAsWatchable
  module Shoulda
    module Matchers
      
      def act_as_watchable
        ActAsWatchableMatcher.new
      end

      class ActAsWatchableMatcher
        def initialize
          @message = ""
        end

        def matches? subject
          @subject = subject
          responds?
        end

        def failure_message
          @message
        end

        def description
          "act as watchable"
        end

        protected
          def responds?
            [:save_watchables, :watchables_attributes=, :attributes_changed?, :deliver_email_for, :should_deliver_email_for?].each do |method|
              unless @subject.new.respond_to?("#{method}")
                @message = "\n\"#{@subject}.#{method}\" should respond but does not"
                return false
              end
            end
            true
          end

      end
    end
  end
end

class Test::Unit::TestCase #:nodoc:
  extend ActsAsWatchable::Shoulda::Matchers
end
