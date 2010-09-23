class Query < ActiveRecord::Base
  serialize :columns
  serialize :criteria
  serialize :order
  serialize :group
  serialize :per_page
  
  before_validation :prepare_attributes
  
  belongs_to :creator, :class_name => 'User'
  
  validates_presence_of     :name, :creator_id, :page_name, :columns
  validates_presence_of     :creator,        :if => :creator_id
  validates_numericality_of :per_page,       :if => :per_page
  validates_length_of       :columns,        :minimum => 1 
  validates_inclusion_of    :public_access,  :in => [true, false]
  validates_inclusion_of    :search_type, :in => ['and', 'or', 'not']
  
  validate :validates_criteria, :validates_order, :validates_serialized_attributes, :validates_page_name, :validates_persistence_of_page_name
  
  cattr_accessor :form_labels
  
  @@form_labels = Hash.new
  @@form_labels[:name]          = "Nom :"
  @@form_labels[:public_access] = "Public :"
  @@form_labels[:per_page]      = "Par Page :"
  @@form_labels[:search_type]   = "Le résultat doit correspondre à :"
  @@form_labels[:criteria]      = "Critères :"
  @@form_labels[:columns]       = "Colonnes :"
  @@form_labels[:group]         = "Grouper par :"
  @@form_labels[:order]         = "Ordonner par :"
  
  def page_configuration(key = nil)
    hash = HasSearchIndex::HTML_PAGES_OPTIONS[self.page_name.to_sym]
    (hash.nil? || key.nil?) ? hash : hash[key] 
  end
  
  def subject_model
    model ||=  page_configuration(:model)
  end
  
  def is_public?
    public_access
  end
  
  def should_validate?(key)
    !page_configuration(key).nil? && page_configuration(key).any?
  end
  
  def quick_search_attributes
    attributes = page_configuration[:quick_search]
    attributes ? attributes.map {|n| n.is_a?(Hash) ? n.values.first : n } : nil
  end
  
  def quick_search_option
    if quick_search_value && quick_search_attributes
      {:attributes => quick_search_attributes, :value => quick_search_value} 
    end
  end
  
  def search
    options = {}
    options.merge!(criteria || {}).merge!(:quick => quick_search_option, :order => order || [], :group => group || [], :search_type => search_type)
    subject_model.constantize.search_with(options) unless subject_model.nil?
  end
  
  private
        
    def prepare_attributes
      if self.criteria
        self.criteria.each do |key, value|
          value.each{ |n| n.symbolize_keys! if n.is_a?(Hash) } if value.is_a?(Array)
          value.symbolize_keys! if value.is_a?(Hash)
        end
      end
      
      [:columns, :group, :order].each do |option|
        self.send(option).each(&:downcase) if self.send(option)
      end
    end
    
    def validates_serialized_attributes
      if self.page_name
        [:columns, :group].each do |option| 
          next unless self.send(option) && should_validate?(option)
          unless self.send(option).is_a?(Array)
            errors.add(option, "n'est pas au bon format")    
          else
            errors.add(option, "ne correspond pas à la configuration") unless page_configuration(option).include_all?(self.send(option))
          end
        end
      end
    end
    
    def validates_page_name
      unless self.page_name && self.page_name.is_a?(String)
        errors.add(:page_name, "est invalide")
      else
        errors.add(:page_name, "n'existe pas") if HasSearchIndex::HTML_PAGES_OPTIONS.keys.include?(self.page_name)
      end
    end
    
    def validates_persistence_of_page_name
      unless new_record?
        errors.add(:page_name, "a été modifié") if self.page_name != self.page_name_was
      end
    end
    
    def validates_order
      if self.page_name && should_validate?(:order)
        
        unless self.send(:order) && self.send(:order).is_a?(Array)
          errors.add(:order, "n'est pas au bon format")    
        else
          order_attributes = self.send(:order).map {|n| n.split(':').first}
          errors.add(:order, "ne correspond pas à la configuration") unless page_configuration(:order).include_all?(order_attributes)
        end
        errors.add(:order, "contient des erreurs") if self.send(:order).reject {|option| option.split(':').last =~ /(desc|asc)$/ }.any?
      end
    end
    
    def validates_criteria
      if self.page_name && should_validate?(:filters)
        unless self.criteria && self.criteria.is_a?(Hash)
          errors.add(:criteria, "n'est pas au bon format")
        else
          self.criteria.each_value do |options|
            errors.add(:criteria, "est invalide") unless is_valid?(options)
          end
          unless page_configuration(:filters).map {|n| n.is_a?(Hash) ? n.values.first : n}.include_all?(self.criteria.keys)
            errors.add(:criteria, "ne correspond pas à la configuration")
          end
        end
      end
    end
    
    def is_valid?(options)
      if options.is_a?(Array)
        options.each { |n| return false unless n.is_a?(Hash) && n.keys.map(&:to_sym).same_elements?([:value, :action]) }
      elsif options.is_a?(Hash)
        return false unless options.keys.map(&:to_sym).same_elements?([:value, :action])
      end
      return true
    end

end    
