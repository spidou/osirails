require 'test/test_helper'
require File.dirname(__FILE__) + '/../sales_test'

class ProductTest < ActiveSupport::TestCase
  include ProductBaseTest
  
  should_belong_to :product_reference
  should_belong_to :order
  
  should_have_many :checklist_responses
  should_have_many :quote_items
  should_have_many :press_proofs
  should_have_many :mockups
  
  should_validate_presence_of :name, :description, :dimensions
  should_validate_presence_of :order, :product_reference, :with_foreign_key => :default
  
  should_validate_numericality_of :prizegiving, :quantity
  
  should_allow_values_for :prizegiving, nil
  
  should_allow_values_for     :quantity, 0, 1, 1.0
  should_not_allow_values_for :quantity, nil, "", "any string"
  
  #TODO validates_numericality_of :unit_price, :vat, :unless => Proc.new{ |p| p.quote_items.reject{ |i| i.quote.cancelled? }.empty? }
  
  #should_validate_presence_of :reference   #TODO when quote is signed
  #should_validate_uniqueness_of :reference #TODO when quote is signed
  
end
