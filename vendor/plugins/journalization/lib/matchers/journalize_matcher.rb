#  journalization  Copyright (C) 2010  Ronnie Heritiana RABENANDRASANA (http://github.com/rOnnie974)
#
#  Contributor: Mathieu FONTAINE aka spidou (http://github.com/spidou)
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program. If not, see <http://www.gnu.org/licenses/>.

module Journalization
  module Shoulda
    module Matchers
      def journalize params
        JournalizeMatcher.new(params)
      end

      class JournalizeMatcher
        def initialize params
          @params  = params
          @message = ""
        end

        def matches? subject
          @subject = subject
          responds? && callback? && expected_results? && included?
        end

        def failure_message
          @message
        end

        def description
          "journalize as expected"
        end

        protected
          def responds?
            [:journalized_attributes, :journalized_subresources, :journalized_attachments, :journal_identifier_method, :journalized_belongs_to_attributes].each do |method|
              unless @subject.respond_to?("#{method}")
                @message = respond_to_message(method)
                return false
              end
              
              unless @subject.respond_to?("#{method}=")
                @message = respond_to_message("#{method}=")
                return false
              end
            end

            [:last_journal, :parent_infos, :something_journalized].each do |instance_method|
              unless @subject.new.respond_to?("#{instance_method}")
                @message = respond_to_message(instance_method)
                return false
              end

              unless @subject.new.respond_to?("#{instance_method}=")
                @message = respond_to_message("#{instance_method}=")
                return false
              end
            end

            [:last_journalized_value_for, :journalization_record, :init_journal, :journal_identifier, :journals, :journals_with_lines, :journal_identifiers].each do |instance_method|
              unless @subject.new.respond_to?("#{instance_method}")
                @message = respond_to_message(instance_method)
                return false
              end
            end

            unless @subject.private_instance_methods.include?("make_reference_for")
                @message = "\"make_reference_for\" should be included in #{@subject}.instance_private_methods but is not"
              return false
            end
            
            true
          end
          
          def callback?
            unless @subject.after_save.detect {|c| c.method == :journalization_record}
              @message = "\n#{@subject} should call 'journalization_record' after_save"
              return false
            end
            true
          end

          def expected_results?
            has_expected_journalized_attributes?    &&
            has_expected_journalized_subresources?  &&
            has_expected_journalized_attachments?   &&
            has_expected_journal_identifier_method? &&
            has_expected_journalized_belongs_to_attributes?
          end

          def included?
            included = @subject.included_modules.include?(Journalization::Models::Subject)
            @message = "Journalization::Models::Subject should be included in #{@subject}.included_modules but is not" unless included
            included
          end

          def has_expected_journalized_attributes?
            expected_attributes   = @params[:attributes].instance_of?(Symbol) ? [@params[:attributes]] : @params[:attributes]
            expected_attributes ||= []

            expected = expected_attributes == @subject.journalized_attributes
            @message = expected_collection_message("journalized_attributes", expected_attributes, @subject.journalized_attributes) unless expected
            expected
          end

          def has_expected_journalized_subresources?
            expected_subresources = {:has_many => {}, :has_one => {}}

            if @params[:subresources]
              @params[:subresources].each do |subresource|
                if subresource.instance_of?(Symbol)
                  macro = @subject.reflect_on_association(subresource).macro
                  expected_subresources[macro][subresource] = :always
                else
                  subresource.each_pair do |name, restrictions|
                    macro = @subject.reflect_on_association(name).macro
                    expected_subresources[macro][name] = restrictions
                  end
                end
              end
            end

            expected = expected_subresources == @subject.journalized_subresources
            @message = expected_collection_message("journalized_subresources", expected_subresources, @subject.journalized_subresources) unless expected
            expected
          end

          def has_expected_journalized_attachments?
            expected_attachments   = @params[:attachments].instance_of?(Symbol) ? [@params[:attachments]] : @params[:attachments]
            expected_attachments ||= []

            expected = expected_attachments == @subject.journalized_attachments
            @message = expected_collection_message("journalized_attachments", expected_attachments, @subject.journalized_attachments) unless expected
            expected
          end

          def has_expected_journal_identifier_method?
            raise ArgumentError, "Procs are not supported by should_journalize as :identifier_method" if @params[:identifier_method].instance_of?(Proc)
            expected = @params[:identifier_method] == @subject.journal_identifier_method
            @message = expected_collection_message("journal_identifier_method", @params[:identifier_method], @subject.journal_identifier_method) unless expected
            expected
          end
          
          def has_expected_journalized_belongs_to_attributes?
            expected_journalized_belongs_to_attributes = {}
            @subject.journalized_attributes.each do |attribute|
              
              @subject.reflect_on_all_associations(:belongs_to).each do |a|
                foreign_key = (a.options[:foreign_key] ? a.options[:foreign_key] : a.name.to_s + "_id")
                if attribute.to_s == foreign_key
                  expected_journalized_belongs_to_attributes[attribute]              = {}
                  expected_journalized_belongs_to_attributes[attribute][:name]       = a.name.to_s 
                  expected_journalized_belongs_to_attributes[attribute][:class_name] = a.class_name 
                  break
                end
              end
            end
            
            expected = expected_journalized_belongs_to_attributes == @subject.journalized_belongs_to_attributes
            @message = expected_collection_message("journalized_belongs_to_attributes", expected_journalized_belongs_to_attributes, @subject.journalized_belongs_to_attributes) unless expected
            expected
          end

        private
          def respond_to_message(object)
            "\n\"#{@subject}.#{object}\" should respond but does not"
          end

          def expected_collection_message(collection, expected, result)
            "\n<#{expected.inspect}> expected for #{@subject}.#{collection} but was\n<#{result.inspect}>"
          end
      end
    end
  end
end

class Test::Unit::TestCase #:nodoc:
  extend Journalization::Shoulda::Matchers
end
