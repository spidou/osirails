class Order < ActiveRecord::Base
  # Relationships
  belongs_to :society_activity_sector
  belongs_to :order_type
  belongs_to :customer
  belongs_to :establishment
  belongs_to :commercial, :class_name => 'Employee'
  
  has_one :step_commercial
  has_one :step_invoicing
  has_many :order_logs
  has_many :contacts_owners, :as => :has_contact
  has_many :contacts, :source => :contact, :through => :contacts_owners

  # Validations
  validates_presence_of :customer_id, :title, :order_type_id, :commercial_id, :establishment_id
  
  cattr_accessor :form_labels
  @@form_labels = {}
  @@form_labels[:title] = 'Nom du projet :'
  @@form_labels[:order_type] = 'Type de dossier :'
  @@form_labels[:commercial] = 'Commercial :'
  @@form_labels[:establishment] = 'Etablissement concerné :'
  @@form_labels[:contacts] =  'Contact(s) concerné(s) :'
  @@form_labels[:created_at] = 'Date de cr&eacute;ation :'
  @@form_labels[:previsional_start] = 'Date pr&eacute;visionnelle de mise en production :'
  @@form_labels[:previsional_delivery] = 'Date pr&eacute;visionnelle de livraison :'
  
  # Create all orders_steps after create order
  def after_create
    order_type.activated_steps.each do |step|
      if step.parent.nil?
        step.name.camelize.constantize.create(:order_id => self.id)
      else
        s = step.name.camelize.constantize.create(step.parent.name + '_id' => self.send(step.parent.name).id)
        step.checklists.each do |checklist|
          checklist_response = ChecklistResponse.create :checklist_id => checklist.id
          s.checklist_responses << checklist_response  
        end
      end
    end
  end
  
  def current_step
    all_steps.select{ |step| step.respond_to?(:parent_step) }.each do |child|
      return child.original_step if (child.in_progress? || child.unstarted?)
    end
    return nil
  end

  # Return all steps of the order
  def steps
    order_type.sales_processes.collect { |sp| sp.step if sp.activated }
  end

  # Return a has for advance statistics
  def advance
    steps_obj = []
    advance = {}
    steps.each do |step|
      next if step.parent
      steps_obj += send(step.name).children_steps
    end
    advance[:total] = steps_obj.size
    advance[:terminated] = 0
    steps_obj.each { |s| advance[:terminated] += 1 if s.terminated? }
    advance
  end

  def child
    first_level_steps.reverse.each do |child|
      return child unless child.unstarted?
    end
    return first_level_steps.first
  end
  
  # Returns steps of the first level
  # 
  # order:
  #   step_commercial
  #     step_graphic_conception
  #     step_survey
  #     step_estimate
  #   step_invoicing
  #     step_finished
  # 
  # @order.first_level_steps # => [ #<StepCommercial>, #<StepInvoicing> ]
  # 
  def first_level_steps # children
    steps.select{ |step| !step.parent }.map{ |step| send(step.name) }
  end
  
  # Returns all steps
  # 
  # order:
  #   step_commercial
  #     step_graphic_conception
  #   step_invoicing
  #     step_finished
  # 
  # @order.all_steps # => [ #<StepCommercial>, #<StepGraphicConception>, #<StepInvoicing>, #<StepFinished> ]
  # 
  def all_steps # all_children
    first_level_steps.collect { |step| [step] << step.children_steps }.flatten
  end

#  ## Return remarks's order
#  def remarks
#    remarks = []
#    OrdersSteps.find(:all, :conditions => ["order_id = ?", self.id]).each {|order_step| order_step.remarks.each {|remark| remarks << remark} }
#    remarks
#  end

  ## Return missing elements's order
  def missing_elements
    missing_elements = []
    OrdersSteps.find(:all, :conditions => ["order_id = ?", self.id]).each {|order_step| order_step.missing_elements.each {|missing_element| missing_elements << missing_element} }
    missing_elements
  end
  
  def terminated?
    return false unless closed_date?
    children_steps.each do |child|
      return false unless child.terminated?
    end
    true
  end
end
