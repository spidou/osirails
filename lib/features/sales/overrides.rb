module Osirails
  module ContextualMenu
    class Section
      @@section_titles.update({ :order_progress   => "Avancement du projet",
                                :order            => "Dossier",
                                :graphic_items    => "Ressources graphiques",
                                :mockup           => "Maquette",
                                :graphic_document => "Document graphique",
                                :spool_items      => "Travaux en attente",
                                :survey_step      => "Étape \"Survey\"",
                                :estimate_step    => "Étape \"Devis\"",
                                :press_proof_step => "Étape \"BAT\"",
                                :delivery_step    => "Étape \"Livraison\"",
                                :invoice_step     => "Étape \"Factures\"",
                                :quote            => "Devis",
                                :press_proof      => "BAT",
                                :delivery_note    => "Bon de livraison",
                                :invoice          => "Facture" })
    end
  end
end

require_dependency 'society_activity_sector'
require_dependency 'customer'
require_dependency 'factor'
require_dependency 'establishment'
require_dependency 'society_activity_sector'
require_dependency 'application_helper'
require_dependency 'user'

class Customer
  has_many :orders

  def terminated_orders
    orders = []
    self.orders.each { |o| orders << o if o.terminated? }
    orders
  end
end

class Factor
  has_many :invoices
end

class Establishment
  has_many :ship_to_addresses
end

class SocietyActivitySector
  has_and_belongs_to_many :order_types
end

class User
  has_many :graphic_items, :foreign_key => :creator_id
  has_many :graphic_item_spool_items
end

module ApplicationHelper
  private
    # permits to display only steps which are activated for the current order
    def display_menu_entry_with_sales_support(menu, li_options)
      return if menu.name and menu.name.start_with?("step_") and !@order.steps.collect{ |s| s.name }.include?(menu.name)
      display_menu_entry_without_sales_support(menu, li_options)
    end
    
    alias_method_chain :display_menu_entry, :sales_support
end

require 'application'
require_dependency 'customers_controller'
require_dependency 'product_references_controller'

class CustomersController < ApplicationController
  after_filter :detect_request_for_order_creation, :only => :new
  after_filter :redirect_to_new_order, :only => :create
  
  def auto_complete_for_customer_name
    find_options = { :include     => :establishments,
                     :conditions  => [ "thirds.name like ? or establishments.name like ?", "%#{params[:customer][:name]}%", "%#{params[:customer][:name]}%"],
                     :order       => "thirds.name ASC",
                     :limit       => 15 }
    @items = Customer.find(:all, find_options)
    render :inline => "<%= custom_auto_complete_result(@items, 'name', params[:customer][:name]) %>"
  end
  
  private
    def detect_request_for_order_creation
      session[:request_for_order_creation] = params[:order_request] === "1" ? true : false
    end
    
    def redirect_to_new_order
      if @customer.errors.empty? and session[:request_for_order_creation]
        session[:request_for_order_creation] = nil
        erase_redirect_results
        redirect_to( new_order_path(:customer_id => @customer.id) )
      end
    end
end

class ProductReferencesController < ApplicationController
  
  def auto_complete_for_product_reference_reference
    #OPTMIZE use one sql request instead of multiple requests (using has_search_index once it will be improved to accept by_values requests)
    
    keywords = params[:product_reference][:reference].split(" ").collect(&:strip)
    @items = []
    keywords.each do |keyword|
      result = ProductReference.search_with( { 'reference' => keyword, 'name' => keyword, 'description' => keyword, 'product_reference_category.name' => keyword, 'product_reference_category.parent.name' => keyword, :search_type => :or })
      @items = @items.empty? ? result : @items & result
    end
    
    render :partial => 'shared/search_product_reference_auto_complete', :object => @items, :locals => { :fields => "reference designation", :keywords => keywords }
  end
  
end
