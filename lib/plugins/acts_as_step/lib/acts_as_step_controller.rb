module ActsAsStepController
  
  class << self
    def included base #:nodoc:
      base.extend ClassMethods
    end
  end
      
  module ClassMethods
    def acts_as_step_controller options = {}
      default_step_controller_methods(options)
      
      real_step_controller_methods unless options[:sham]
      
      setup_sub_resources unless options[:sham]
    end
    
    private
      def default_step_controller_methods options
        helper :orders
        
        before_filter :lookup_order_environment
        
        class_eval do
          # permits to define in which level of the sales process the order is
          def self.current_order_step
            read_inheritable_attribute(:current_order_step)
          end
          
          def self.current_order_step=(step)
            write_inheritable_attribute(:current_order_step, step)
          end
          
          # return the first level step in which the order is currently
          def self.current_order_path
            unless current_order_step.nil?
              current_order_step.first_parent.path
            else
              "closed"
            end
          end
          
          private
            def lookup_order_environment
              if params[:order_id]  # so we are in an order's sub resource
                @order = Order.find(params[:order_id])
              elsif params[:id]     # if order_id doesn't exist but id, so we want to display '/orders/:id' or '/orders/:id/edit' or anything like that
                @order = Order.find(params[:id])
              else                  # so I guess we want to display '/orders/new'
                @order = Order.new
              end
              
              # define the current order step
              self.class.current_order_step = @order.current_step
              
              # manage logs
              OrderLog.set(@order, current_user, params)
            end
        end
        
        unless options[:sham]
          options = { :step_name => self.controller_name }.merge(options)
        end
        
        if options[:step_name]
          step = Step.find_by_name(options[:step_name].to_s)
          raise "The step '#{options[:step_name]}' doesn't exist. Please check in the config yaml file." if step.nil?
          
          write_inheritable_attribute(:step, step)
          
          class_eval do
            # permits to define the step name in which the controller is mapped
            def self.step
              read_inheritable_attribute(:step)
            end
            
            def self.step_name
              step.name
            end
          end
        end
      end
      
      def real_step_controller_methods
        before_filter :lookup_step_environment
        before_filter :should_display_edit,     :only => [ :index, :show ]
        after_filter  :update_step_status,      :only => :update
        
        class_eval do
          # return if the controller should use remarks
          def self.has_remarks?
            step_name.camelize.constantize.instance_methods.include?('remarks')
          end
          
          # return if the controller should use checklists
          def self.has_checklists?
            step_name.camelize.constantize.instance_methods.include?('checklist_responses')
          end
          
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
              if params[:format].nil? and (params[:action] == "index" or params[:action] == "show") and can_edit?(current_user)
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
                
                erase_render_results
                redirect_to path
              end
            end
        end
        
      end
      
      def setup_sub_resources
        if has_remarks?
          helper :remarks
          before_filter :assign_user_in_remark_attributes, :only => :update
        end
        
        if has_checklists?
          helper :checklists
        end
        
        class_eval do
          private
            def assign_user_in_remark_attributes
              if params[self.class.step_name][:remark_attributes]
                params[self.class.step_name][:remark_attributes].each do |remark_attributes|
                  remark_attributes[:user_id] = current_user.id
                end
              end
            end
        end
      end
  end
end

if Object.const_defined?("ActionController")
  ActionController::Base.send(:include, ActsAsStepController)
end
