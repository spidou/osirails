module Journalization
  Journalization.const_set("SubjectsClassName",[]) unless Journalization.const_defined?("SubjectsClassName")
  module Models
    module Subject
      class << self
        def included base #:nodoc:
          base.extend ClassMethods
        end
      end

      module ClassMethods
        def journalize params = {}
          cattr_accessor :journalized_attributes, :journalized_attachments, :journalized_subresources, :journal_identifier_method, :journalized_belongs_to_attributes

          self.journalized_attributes   = []                                unless self.journalized_attributes
          self.journalized_attachments  = []                                unless self.journalized_attachments
          self.journalized_subresources = {:has_many => {}, :has_one => {}} unless self.journalized_subresources
          
          self.journalized_belongs_to_attributes = {} unless self.journalized_belongs_to_attributes

          if !params.include?(:attributes) && !params.include?(:attachments) && !params.include?(:subresources) && !params.include?(:identifier_method)
              self.journalized_attributes == [] && self.journalized_attachments == [] && self.journalized_subresources = {:has_many => {}, :has_one => {}} && self.journal_identifier_method.nil?
            raise ArgumentError, "journalize expected at least one of the following params -> :attributes, :attachments, :subresources, :identifier_method"
          end
          
          if params.include?(:attributes)
            message = ":attributes expected a symbol or an array of symbols"
            if params[:attributes].instance_of?(Array) && params[:attributes].any?
              params[:attributes].each do |attribute|
                raise ArgumentError, message unless attribute.instance_of?(Symbol)

                self.journalized_attributes << attribute unless self.journalized_attributes.include?(attribute)
              end
            elsif params[:attributes].instance_of?(Symbol)
              self.journalized_attributes << params[:attributes] unless self.journalized_attributes.include?(params[:attributes])
            else
              raise ArgumentError, message
            end

            self.journalized_attributes.each do |attribute|
              raise NoMethodError, "undefined attribute or method '#{attribute}' for #{self.name}" unless self.column_names.include?(attribute.to_s)
              
              self.reflect_on_all_associations(:belongs_to).each do |a|
                foreign_key   = a.options[:foreign_key]
                foreign_key ||= a.class_name.underscore + "_id"
                
                if attribute.to_s == foreign_key
                  self.journalized_belongs_to_attributes[attribute] = a.class_name.underscore
                  break
                end
              end
            end
          end

          if params.include?(:attachments)
            message = ":attachments expected a symbol or an array of symbols"
            if params[:attachments].instance_of?(Array) && params[:attachments].any?
              params[:attachments].each do |attribute|
                raise ArgumentError, message unless attribute.instance_of?(Symbol)
                self.journalized_attachments << attribute unless self.journalized_attachments.include?(attribute)
              end
            elsif params[:attachments].instance_of?(Symbol)
              self.journalized_attachments << params[:attachments] unless self.journalized_attachments.include?(params[:attachments])
            else
              raise ArgumentError, message
            end

            self.journalized_attachments.each do |attachment|
              raise NoMethodError, "'#{attachment}' is not recognized as an attachment method for #{self}" unless self.new.respond_to?(attachment.to_s) && self.new.send(attachment.to_s).class == Paperclip::Attachment
              ["#{attachment}_file_name".to_sym, "#{attachment}_file_size".to_sym].each {|attribute| self.journalized_attributes.delete(attribute)}
            end
          end

          if params.include?(:subresources)
            message = ":subresources expected an array with symbols of relationships or hash whose keys are the relationships and values are the restrictions (among :create_and_destroy or :update)"
            if params[:subresources].instance_of?(Array) && params[:subresources].any?
              names_and_restrictions = {}
              params[:subresources].each do |relationship|
                if relationship.instance_of?(Symbol)
                  name        = relationship
                  restriction = :always
                  
                  names_and_restrictions[name] = restriction
                elsif relationship.instance_of?(Hash) && relationship.any?
                  relationship.each_pair do |name, restriction|
                    message = ":#{name} expected a symbol among :create_and_destroy and :update"
                    raise ArgumentError, message unless [:create_and_destroy, :update].include?(restriction)
                    
                    names_and_restrictions[name] = restriction
                  end
                else
                  raise ArgumentError, message
                end
              end
                
              names_and_restrictions.each_pair do |name, restriction|
                reflection = self.reflect_on_association(name)
                raise "undefined association method '#{name}' for #{self.name}" unless reflection

                macro = reflection.macro
                raise ArgumentError, "forbidden association method '#{name}' for #{self.name}. It should be :has_many or :has_one" unless [:has_many, :has_one].include?(macro)
                
                self.journalized_subresources[macro][name.to_sym] = restriction unless self.journalized_subresources[macro].include?(name.to_sym)
              end
            else
              raise ArgumentError, message
            end
          end

          if params.include?(:identifier_method)
            raise ArgumentError, ":identifier expected a symbol or a string corresponding to a method name" unless params[:identifier_method].instance_of?(Symbol) || params[:identifier_method].instance_of?(String)
            self.journal_identifier_method = params[:identifier_method]
          end
          
          Journalization::SubjectsClassName.delete(self.name) unless self.new.respond_to?("journalization_record")

          unless Journalization::SubjectsClassName.include?(self.name)
            class_eval do
              Journalization::SubjectsClassName << self.name
              attr_accessor :last_journal, :parent_infos, :something_journalized
              
              after_save :journalization_record
              after_save :update_journalization_actor

              def journals
                Journal.all.select {|j| j.journalized_type == self.class.name && j.journalized_id == self.id}
              end
              
              def journals_with_lines
                journals.select {|j| j.journal_lines.any?}
              end
              
              def journal_identifiers
                JournalIdentifier.all.select {|j| j.journalized_type == self.class.name && j.journalized_id == self.id}
              end
              
              def last_journalized_value_for property_string
                result = self.class.find_by_sql("SELECT new_value FROM journal_lines INNER JOIN journals ON journal_lines.journal_id = journals.id WHERE journals.journalized_type = '#{self.class.name}' AND journals.journalized_id = #{self.id} AND journal_lines.property = '#{property_string}' AND journal_lines.property_id IS NULL ORDER BY journals.created_at DESC, journals.id DESC LIMIT 1")
                result.any? ? result.first.new_value : nil
              end
              
              def update_journalization_actor
                if Journalization.const_defined?("ActorClassName") && !Journalization::ActorClassName.nil? && self.last_journal.respond_to?(:actor) && self.last_journal.actor
                  actor = self.last_journal.actor(true)
                  actor_identifier = actor.journal_identifier
                  actor_class_identifier_method = actor.class.journal_identifier_method
                  actor.journalization_record(true) if !actor_identifier || actor.send(actor_class_identifier_method) != actor_identifier.new_value
                end
              end

              def journalization_record(without_actor=false)
                @without_actor = without_actor
                
                self.something_journalized = false
                
                [self.class.journalized_attributes, self.class.journalized_attachments].each do |array|
                  array.each do |object_name|
                    will_journalize = {}
                    
                    if array == self.class.journalized_attributes
                      property = object_name.to_s
                      
                      new_value = self.class.find(self).send(property).to_s
                      old_value = last_journalized_value_for(property)
                      
                      will_journalize[property] = [old_value, new_value] if new_value != old_value
                    else
                      attachment_infos = {}
                      {:name => "#{object_name}_file_name", :size => "#{object_name}_file_size"}.each_pair do |key, value|
                        attachment_infos[key] = [last_journalized_value_for(value), self.class.find(self).send(value).to_s]
                      end
                      
                      if attachment_infos[:name][1] != attachment_infos[:name][0] || attachment_infos[:size][1] != attachment_infos[:size][0]
                        will_journalize["#{object_name}_file_name"] = [attachment_infos[:name][0], attachment_infos[:name][1]]
                        will_journalize["#{object_name}_file_size"] = [attachment_infos[:size][0], attachment_infos[:size][1]]
                      end
                    end
                    
                    will_journalize.each_pair do |property, changes|
                      old_value = changes[0]
                      new_value = changes[1]
                      
                      unless old_value.blank? && new_value.blank?
                        init_journal unless self.something_journalized
                        self.last_journal.journal_lines.create(:property => property, :old_value => old_value, :new_value => new_value)
                        self.something_journalized = true
                      end
                    end
                  end
                end
                
                [:has_one, :has_many].each do |macro|
                  self.class.journalized_subresources[macro].each_pair do |resource_type, restrictions|
                    has_one_macro = macro == :has_one
                    
                    property = resource_type.to_s
                    
                    if has_one_macro 
                      subresource = self.class.find(self).send(property)
                      new_value = subresource.id.to_s if subresource
                    else
                      new_value = self.class.find(self).send("#{property.singularize}_ids")
                    end
                    
                    old_value = last_journalized_value_for(property)
                    old_value ||= [].to_yaml unless has_one_macro
                    
                    old_value = YAML.load(old_value) unless has_one_macro
                    
                    if new_value != old_value
                    
                      on_create_and_destroy  = [:create_and_destroy, :always].include?(restrictions)
                      
                      if on_create_and_destroy
                        unless has_one_macro
                          old_value   = old_value.to_yaml 
                          new_value   = new_value.to_yaml 
                        end
                        
                        init_journal unless self.something_journalized
                        self.last_journal.journal_lines.create(:property => property, :old_value => old_value, :new_value => new_value)
                        self.something_journalized = true
                      end
                    end
                  
                    if [:update, :always].include?(restrictions)
                      if macro == :has_one
                        instance = self.send(resource_type.to_s)
                        make_reference_for(instance,resource_type.to_s)
                      else
                        self.send(resource_type.to_s).each do |instance|
                          make_reference_for(instance,resource_type.to_s)
                        end
                      end
                    end
                  end
                end
                
                if self.last_journal && self.parent_infos && self.parent_infos.size == 2
                  parent        = self.parent_infos[0]
                  resource_type = self.parent_infos[1]

                  parent.init_journal unless parent.something_journalized
                  parent.last_journal.journal_lines.create(:property => resource_type, :property_id => self.id, :referenced_journal => self.last_journal)
                  parent.something_journalized = true
                end
                
                identifier_was = self.journal_identifier.nil? ? nil : self.journal_identifier.new_value
                identifier = self.send(self.class.journal_identifier_method) unless self.class.journal_identifier_method.nil?
                if identifier != identifier_was
                  init_journal unless self.something_journalized
                  JournalIdentifier.create(:journalized_type => self.class.name, :journalized_id => self.id, :old_value => identifier_was, :new_value => identifier, :journal => self.last_journal)
                  self.something_journalized = true
                end
              end

              def init_journal
                self.last_journal = Journal.create(:journalized_type => self.class.name, :journalized_id => self.id) do |j|
                  if Journalization.const_defined?("ActorClassName") && !Journalization::ActorClassName.nil? && j.respond_to?(:actor)
                    j.actor = Journalization::ActorClassName.constantize.journalization_actor_object unless @without_actor
                  end
                end
              end

              def journal_identifier(datetime = Time.now)
                journal_identifiers.select {|i| i.journal.created_at <= datetime}.sort_by {|i| i.journal.created_at}.last
              end
              
              private
                def make_reference_for(instance, resource_type)
                  if instance.respond_to?("journals")
                    if instance.last_journal && instance.last_journal.journal_lines.any?
                      init_journal unless self.something_journalized
                      self.last_journal.journal_lines.create(:property => resource_type, :property_id => instance.id, :referenced_journal => instance.last_journal)
                      self.something_journalized = true
                    else
                      instance.parent_infos = [self, resource_type]
                    end
                  end
                end
            end
          end
        end
      end
    end
  end
end

# Set it all up.
if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, Journalization::Models::Subject)
end
