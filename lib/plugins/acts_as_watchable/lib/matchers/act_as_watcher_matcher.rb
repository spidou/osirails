module ActsAsWatchable
  module Shoulda
    module Matchers
      
      def act_as_watcher 
        ActAsWatcherMatcher.new
      end

      class ActAsWatcherMatcher
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
          "act as watcher"
        end

        protected
          def responds?
            [:watcher_email, :watcher_type].each do |method|
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
