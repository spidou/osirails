# ActsAsStep
require 'active_record'

module ActiveRecord
  module Acts #:nodoc:
    module Step #:nodoc:
      
      def self.included(mod)
        mod.extend(ClassMethods)
      end
      
      module ClassMethods
        def acts_as_step
          # this is at the class level
          # add any class level manipulations you need here, like has_many, etc.
          extend ActiveRecord::Acts::Step::SingletonMethods
          include ActiveRecord::Acts::Step::InstanceMethods
          
          # Plugins
          acts_as_file
          
          # Relationships
          has_many :remarks, :as => :has_remark
          has_many :checklist_responses, :as => :has_checklist_response
          has_many :missing_elements
          
          # attr_reader :status # FIXME Protect status attr
        end
      end
      
      # Adds SingletonMethods
      module SingletonMethods
        def step
          'Step'.constantize.find_by_name(self.name.tableize.singularize)
        end
        
        def sibling_steps
          sibling.collect { |s| s.step }
        end
      end
      
      # Adds instance methods.
      module InstanceMethods
        def name
          self.class.name.tableize.singularize
        end
        
        def parent
          return nil if self.class.parent.nil?
          send(self.class.step.parent.name)
        end
        
        def childrens
          self.steps.collect { |s| send(s.name) }
        end
        
        def step
          'Step'.constantize.find_by_name(self.class.name.tableize.singularize)
        end
        
        def steps
          step = 'Step'.constantize.find_by_name(self.class.name.tableize.singularize)
          'Step'.constantize.find(:all, :conditions => ["parent_id = ?", step])
        end
        
        def sibling
          parent.childrens
        end
        
        def order
          parent ? parent.order : order
        end
        
        def unstarted!
          self.status = 'unstarted'
          self.save
        end
        
        def in_progress!
          self.status = 'in_progress'
          self.start_date = DateTime.now
          self.save
        end
        
        def terminated!
          self.status = 'terminated'
          self.end_date = DateTime.now
          self.save
        end
        
        def unstarted?
          status == 'unstarted'
        end

        def in_progress?
          status == 'in_progress'
        end

        def terminated?
          status == 'terminated'
        end
        
        def uncomplete?
          dependencies_are_terminated? && unstarted?
        end
                
        def dependencies
          deps = []
          sibling.each do |s|
            step_deps = step.dependencies.collect { |step| step.name }
            deps << s if step_deps.include?(s.name)
          end
          deps
        end
        
        def dependencies_are_unstarted?
          dependencies_are_in_status('unstarted')
        end
        
        def dependencies_are_in_progress?
          dependencies_are_in_status('in_progress')
        end
        
        def dependencies_are_terminated?
          dependencies_are_in_status('terminated')
        end
        
        private
        
        def dependencies_are_in_status(status)
          dependencies.each { |s| return false unless s.status == status }
          true
        end
        
      end
      
    end
  end
end