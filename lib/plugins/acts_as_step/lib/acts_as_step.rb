module ActsAsStep
  
  class << self
    def included base #:nodoc:
      base.extend ClassMethods
    end
  end
      
  module ClassMethods
    def acts_as_step options = {}
      extend SingletonMethods
      include InstanceMethods
      
      options = { :step_name         => self.singularized_table_name,
                  :remarks           => true,
                  :checklists        => true,
                  :missing_elements  => true
                }.merge!(options)
      
      step = Step.find_by_name(options[:step_name])
      raise "The step '#{options[:step_name]}' doesn't exist. Please check in the config yaml file." if step.nil?
      
      if (step_parent = step.parent) # so it's a child step
        parent_step_model = step_parent.name.camelize.constantize
        belongs_to :parent_step, :class_name => step_parent.name.camelize, :foreign_key => "#{parent_step_model.table_name.singularize}_id"
        
        class_eval do
          def order
            parent_step.order
          end
        end
      elsif (step_children = step.children) # so it's a parent step
        belongs_to :order
        
        write_inheritable_attribute(:list_children_steps, step_children.collect{ |child| child.name })
        
        step_children.each do |child|
          step_model = step.name.camelize.constantize
          has_one child.name, :foreign_key => "#{step_model.table_name.singularize}_id", :dependent => :destroy
        end
        
        class_eval do
          def children_steps
            self.class.list_children_steps.collect{ |step| send(step) }
          end
          
          private
            def self.list_children_steps
              read_inheritable_attribute(:list_children_steps)
            end
        end
      end
      
      write_inheritable_attribute(:original_step_name, options[:step_name])
      write_inheritable_attribute(:original_step, step)
      
      if options[:remarks]
        has_many              :remarks,     :as => :has_remark, :order => "created_at DESC"
        validates_associated  :remarks
        after_update          :save_remarks
      end
      
      if options[:checklists]
        has_many              :checklist_responses,     :as => :has_checklist_response
        validates_associated  :checklist_responses
        after_update          :save_checklist_responses
      end
      
      if options[:missing_elements]
        has_many :missing_elements
      end
      
      attr_protected :status
      
      # retrieve all instances of this step currently in progress or pending
      named_scope :currently_pending_or_in_progress, :conditions => [ "status IN ('pending', 'in_progress')" ]
      
      # retrieve all orders which are currently in progress or pending in this step
      class_eval do
        def self.orders
          currently_pending_or_in_progress.collect(&:order).sort_by(&:previsional_delivery)
        end
      end
    end
  end
  
  module SingletonMethods
    def original_step
      read_inheritable_attribute(:original_step)
    end
    
    def original_step_name
      read_inheritable_attribute(:original_step_name)
    end
  end
  
  module InstanceMethods
    UNSTARTED   = 'unstarted'
    PENDING     = 'pending'
    IN_PROGRESS = 'in_progress'
    TERMINATED  = 'terminated'
    
    def original_step
      self.class.original_step
    end
    
    def original_step_name
      self.class.original_step_name
    end
    
    def after_create
      unstarted!
    end
    
    def after_update
      if respond_to?(:parent_step)
        if in_progress? and !parent_step.in_progress?
          parent_step.in_progress!
        elsif terminated?
          if self_and_siblings_steps.select{ |s| s.terminated? }.size == self_and_siblings_steps.size
            parent_step.terminated!
          else
            parent_step.in_progress!
          end
        end
      end
    end
    
    def remark_attributes=(remark_attributes)
      remark_attributes.each do |attributes|
        remarks.build(attributes)
      end
    end
    
    def save_remarks
      remarks.each do |r|
        r.save(false) if r.new_record?
      end
    end
    
    def checklist_response_attributes=(checklist_response_attributes)
      checklist_response_attributes.each do |id, attributes|
        checklist_response = checklist_responses.detect { |c| c.id == id.to_i }
        checklist_response.attributes = attributes
      end
    end
    
    def save_checklist_responses
      checklist_responses.each do |c|
        c.save(false) if c.changed?
      end
    end
    
    def siblings_steps
      self_and_siblings_steps - [self]
    end
    
    def self_and_siblings_steps
      respond_to?(:parent_step) ? parent_step.children_steps : order.first_level_steps
    end
    
    def next
      collection = self_and_siblings_steps
      index = collection.index(self) + 1
      index >= collection.size ? nil : collection[index]
    end
    
    def previous
      collection = self_and_siblings_steps
      index = collection.index(self) - 1
      index < 0 ? nil : collection[index]
    end
    
    def unstarted!
      status.blank? ? update_attribute(:status, UNSTARTED) : false
    end
    
    def pending!
      unstarted? ? update_attribute(:status, PENDING) : false
    end
    
    def in_progress!
      if pending? or unstarted?
        update_attribute(:status, IN_PROGRESS)
        update_attribute(:started_at, DateTime.now)
      else
        false
      end
    end
    
    def terminated!
      if in_progress? or pending? or unstarted?
        update_attribute(:status, TERMINATED)
        update_attribute(:finished_at, DateTime.now)
        if next_step = self.next
          next_step.pending!
        end
      else
        false
      end
    end
    
    def unstarted?
      status == UNSTARTED
    end
    
    def pending?
      status == PENDING
    end

    def in_progress?
      status == IN_PROGRESS
    end

    def terminated?
      status == TERMINATED
    end
    
    def uncomplete?
      dependencies_are_terminated? && unstarted?
    end
            
    def dependencies_steps
      deps = []
      siblings_steps.each do |sibling|
        deps << sibling if self.original_step.dependencies.collect{ |step| step.name }.include?(sibling.original_step_name)
      end
      deps
    end
    
    def dependencies_are_unstarted?
      dependencies_are_in_status(UNSTARTED)
    end
    
    def dependencies_are_pending?
      dependencies_are_in_status(PENDING)
    end
    
    def dependencies_are_in_progress?
      dependencies_are_in_status(IN_PROGRESS)
    end
    
    def dependencies_are_terminated?
      dependencies_are_in_status(TERMINATED)
    end
    
    private
      def dependencies_are_in_status(status)
        dependencies_steps.each { |s| return false unless s.status == status }
        true
      end
  end
end

if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, ActsAsStep)
end
