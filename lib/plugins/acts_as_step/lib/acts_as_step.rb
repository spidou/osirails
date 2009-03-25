module ActsAsStep
  
  class << self
    def included base #:nodoc:
      base.extend ClassMethods
    end
  end
      
  module ClassMethods
    def acts_as_step options = {}
      include SingletonMethods
      include InstanceMethods
      
      if options[:children] # so if it's a parent step
        belongs_to :order
        
        write_inheritable_attribute(:list_children_steps, options[:children])
        options[:children].each do |child|
          has_one child
        end
        
        class_eval do
          def self.list_children_steps
            read_inheritable_attribute(:list_children_steps)
          end
          
          def children_steps
            self.class.list_children_steps.collect{ |c| send(c) }.flatten
          end
        end
        
      elsif options[:parent] # so if it's a child step
        belongs_to :parent_step, :class_name => options[:parent].to_s.camelize, :foreign_key => "#{options[:parent]}_id"
        
        class_eval do
          def order
            parent_step.order
          end
        end
        
      end
      
      write_inheritable_attribute(:original_step_name, self.singularized_table_name)
      write_inheritable_attribute(:original_step, Step.find_by_name(self.singularized_table_name))
      
      class_eval do
        def self.original_step
          read_inheritable_attribute(:original_step)
        end
        
        def self.original_step_name
          read_inheritable_attribute(:original_step_name)
        end
      end
      
      unless options[:remarks] == false
        has_many              :remarks,     :as => :has_remark
        validates_associated  :remarks
        after_update          :save_remarks
      end
      
      unless options[:checklists] == false
        has_many              :checklist_responses,     :as => :has_checklist_response
        validates_associated  :checklist_responses
        after_update          :save_checklist_responses
      end
      
      unless options[:missings_elements] == false
        has_many :missing_elements
      end
      
      attr_protected :status
    end
  end
  
  module SingletonMethods
#    def sibling_steps
#      sibling.collect { |s| s.step }
#    end
  end
  
  module InstanceMethods
    UNSTARTED   = 'unstarted'
    IN_PROGRESS = 'in_progress'
    TERMINATED  = 'terminated'
    
    def after_create
      unstarted!
    end
    
    def after_update
      if in_progress? and respond_to?(:parent_step) and !parent_step.in_progress?
        parent_step.in_progress!
      elsif terminated? and respond_to?(:parent_step)
        if self_and_siblings_steps.select{ |s| s.terminated? }.size == self_and_siblings_steps.size
          parent_step.terminated!
        else
          parent_step.in_progress!
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
    
    def siblings_steps # sibling
      self_and_siblings_steps.select{ |s| s != self }
    end
    
    def self_and_siblings_steps
      respond_to?(:parent_step) ? parent_step.children_steps : []
    end
    
    def unstarted!
      update_attribute(:status, UNSTARTED) unless unstarted?
    end
    
    def in_progress!
      unless in_progress?
        update_attribute(:status, IN_PROGRESS)
        update_attribute(:start_date, DateTime.now)
      end
    end
    
    def terminated!
      unless terminated?
        update_attribute(:status, TERMINATED)
        update_attribute(:end_date, DateTime.now)
      end
    end
    
    def unstarted?
      status == UNSTARTED
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
        deps << sibling if self.class.original_step.dependencies.collect{ |step| step.name }.include?(sibling.class.original_step_name)
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
        dependencies_steps.each { |s| return false unless s.status == status }
        true
      end
  end
end

if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, ActsAsStep)
end
