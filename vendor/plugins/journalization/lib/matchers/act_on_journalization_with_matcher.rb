module Journalization
  module Shoulda
    module Matchers
      def act_on_journalization_with params = nil
        ActOnJournalizationWithMatcher.new(params)
      end

      class ActOnJournalizationWithMatcher
        def initialize params = nil
          @params  = params
          @message = ""
        end

        def matches? subject
          @subject = subject
          responds? && callback? && included?
        end

        def failure_message
          @message
        end

        def description
          "act on journalization with :#{@params}"
        end

        protected
          def responds?
            [:journalization_actor_object, :journalization_actor_object=, :reset_journalization_actor_object].each do |method|
              unless @subject.respond_to?("#{method}")
                @message = "\n\"#{@subject}.#{method}\" should respond but does not"
                return false
              end
            end
            true
          end
          
          def callback?
            journal_actor_class_name = Journal.reflect_on_association(:actor).options[:class_name]
            unless journal_actor_class_name == @subject.class_name
              @message = "#{@subject.class_name} excepted for the \"belongs_to :actor\" association class_name but was #{journal_actor_class_name}"
              return false
            end
            true
          end
          
          def included?
            included = @subject.included_modules.include?(Journalization::Models::Actor)
            @message = "Journalization::Models::Actorsshould be included in #{@subject}.included_modules but is not" unless included
            included
          end
      end
    end
  end
end

class Test::Unit::TestCase #:nodoc:
  extend Journalization::Shoulda::Matchers
end
