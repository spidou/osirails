module ActsAsStepController
  
  class << self
    def included base #:nodoc:
      base.extend ClassMethods
    end
  end
      
  module ClassMethods
    def acts_as_step_controller options = {}
      default_step_controller_methods
      real_step_controller_methods(options) unless options[:sham]
    end
    
    private
      def default_step_controller_methods
        helper :orders
        
        before_filter :lookup_order_environment
        before_filter :assign_user_in_remark_attributes, :only => :update
        
        class_eval do
          # permits to define in which level of the sales process the order is
          def self.current_order_step
            read_inheritable_attribute(:current_order_step)
          end
          
          def self.current_order_step=(step)
            raise "It's impossible to define in which step the order is! Please verify if your steps are properly configured in the yaml file." if step.nil?
            write_inheritable_attribute(:current_order_step, step)
          end
          
          # return the first level step in which the order is currently
          def self.current_order_path
            return nil if current_order_step.nil?
            current_order_step.first_parent.path
          end
          
          private
            def lookup_order_environment
              @order = Order.find(params[:order_id])
              
              # manage logs
              OrderLog.set(@order, current_user, params)
              
              # define the current order step
              self.class.current_order_step = @order.current_step
            end
            
            def assign_user_in_remark_attributes
              if params[self.class.step_name][:remark_attributes]
                params[self.class.step_name][:remark_attributes].each do |remark_attributes|
                  remark_attributes[:user_id] = current_user.id
                end
              end
            end
        end
      end
      
      def real_step_controller_methods options
        before_filter :lookup_step_environment
        before_filter :should_display_edit,     :only => [ :index, :show ]
        after_filter  :update_step_status,      :only => :update
        
        options = { :step_name => self.controller_name }.merge!(options)
        
        step = Step.find_by_name(options[:step_name].to_s)
        raise "The step '#{options[:step_name]}' doesn't exist. Please check in the config yaml file." if step.nil?
        #parent_step = step.parent
        
        write_inheritable_attribute(:step, step)
        #write_inheritable_attribute(:parent_step, parent_step)
        
        class_eval do
          ## permits to define the parent step name in which the controller is mapped
          #def self.parent_step
          #  read_inheritable_attribute(:parent_step)
          #end
          #
          #def self.parent_step_name
          #  read_inheritable_attribute(:parent_step).nil? ? nil : read_inheritable_attribute(:parent_step).name
          #end
          
          # permits to define the step name in which the controller is mapped
          def self.step
            read_inheritable_attribute(:step)
          end
          
          def self.step_name
            step.name
          end
        end
        
        model_step = self.step_name.camelize.constantize
        helper :remarks     if model_step.instance_methods.include?('remarks')
        helper :checklists  if model_step.instance_methods.include?('checklist_responses')
        
        class_eval do
          private
            def lookup_step_environment
              step = self.class.step
              parent_step = step.first_parent
              if parent_step != step
                @step = @order.send(parent_step.name).send(step.name)
              else
                @step = @order.send(step.name)
              end
            end
            
            def should_display_edit
              if (params[:action] == "index" or params[:action] == "show") and can_edit?(current_user)
                redirect_to :action => "edit"
              end
            end
            
            def update_step_status
              if @step.errors.empty?
                if params[:close_step]
                  @step.terminated!
                  path = send("order_path", @order)
                else
                  @step.in_progress! unless @step.terminated?
                  path = send("order_#{self.class.step_name[0..self.class.step_name.size]}_path", @order)
                end
                
                erase_render_results # permits to override the 'render :action => :edit' in the controller
                redirect_to path
              end
            end
        end
        
      end
  end
end

if Object.const_defined?("ActionController")
  ActionController::Base.send(:include, ActsAsStepController)
end
