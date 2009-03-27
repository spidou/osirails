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
        
        # permits to define in which step the order is
        cattr_accessor :current_order_step
        
        before_filter :lookup_order_environment
        before_filter :assign_user_in_remark_attributes, :only => :update
        
        class_eval do
          private
            def lookup_order_environment
              @order = Order.find(params[:order_id])
              
              # manage logs
              OrderLog.set(@order, current_user, params)
              
              # define the current order step
              self.current_order_step = @order.current_step.first_parent.path
              raise "It's impossible to define in which step the order is! Please verify if your steps are properly configured." if self.current_order_step.nil?
            end
            
            def assign_user_in_remark_attributes
              if params[@@step_name][:remark_attributes]
                params[@@step_name][:remark_attributes].each do |remark_attributes|
                  remark_attributes[:user_id] = current_user.id
                end
              end
            end
            
            def self.current_order_step
              read_inheritable_attribute(:current_order_step)
            end
            
            def self.current_order_step=(step)
              write_inheritable_attribute(:current_order_step, step)
            end
        end
      end
      
      def real_step_controller_methods options
        # permits to define the step name and parent step name in which the controller is mapped
        cattr_accessor :step_name, :parent_step_name
        
        before_filter :lookup_step_environment
        before_filter :should_display_edit,     :only => :show
        after_filter  :update_step_status,      :only => :update
        
        @@parent_step_name = options[:parent] ? options[:parent] : nil    
        @@step_name = options[:name] ? options[:name] : "step_#{self.controller_name}"
        
        model_step = @@step_name.camelize.constantize
        helper :remarks     if model_step.instance_methods.include?('remarks')
        helper :checklists  if model_step.instance_methods.include?('checklist_responses')
        
        class_eval do
          private
            def lookup_step_environment
              if @@parent_step_name
                @step = @order.send(@@parent_step_name).send(@@step_name)
              else
                @step = @order.send(@@step_name)
              end
            end
            
            def should_display_edit
              if params[:action] == "show" and can_edit?(current_user)
                redirect_to :action => "edit"
              end
            end
            
            def update_step_status
              if params[:close_step]
                @step.terminated!
                path = send("order_path", @order)
              else
                @step.in_progress! unless @step.terminated?
                path = send("order_#{@@step_name[5..@@step_name.size]}_path", @order)
              end
              
              erase_render_results # permits to override the 'render :action => :edit' in the controller
              redirect_to path
            end
        end
        
      end
  end
end

if Object.const_defined?("ActionController")
  ActionController::Base.send(:include, ActsAsStepController)
end
