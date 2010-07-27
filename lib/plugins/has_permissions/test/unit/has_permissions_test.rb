require File.dirname(__FILE__) + '/../has_permissions_helper'

class HasPermissionsTest < ActiveSupport::TestCase
  
  context "An instance of a class in with we call the method 'has_permissions :as_instance'" do
    setup do
      ActiveRecord::Base.connection.create_table :firsts do |t|
        t.string :column1
      end
      
      @first_instance = First.new
    end
    
    teardown do 
      ActiveRecord::Base.connection.drop_table :firsts
    end
    
    should "respond to the methods can_*?" do
      assert @first_instance.respond_to?(:can_view?), "#{@first_instance} doesn't respond to can_view?"
      assert @first_instance.respond_to?(:can_list?), "#{@first_instance} doesn't respond to can_list?"
      assert @first_instance.respond_to?(:can_add?), "#{@first_instance} doesn't respond to can_add?"
      assert @first_instance.respond_to?(:can_edit?), "#{@first_instance} doesn't respond to can_edit?"
      assert @first_instance.respond_to?(:can_delete?), "#{@first_instance} doesn't respond to can_delete?"
    end
  end
  
  context "A class in with we call the method 'has_permissions :as_business_object'" do
    setup do
      ActiveRecord::Base.connection.create_table :seconds do |t|
        t.string :column1
      end
      
      @second_class = Second
    end
    
    teardown do
      ActiveRecord::Base.connection.drop_table :seconds
    end
    
    should "respond to the methods can_*?" do
      assert @second_class.respond_to?(:can_view?), "#{@second_class} doesn't respond to can_view?"
      assert @second_class.respond_to?(:can_list?), "#{@second_class} doesn't respond to can_list?"
      assert @second_class.respond_to?(:can_add?), "#{@second_class} doesn't respond to can_add?"
      assert @second_class.respond_to?(:can_edit?), "#{@second_class} doesn't respond to can_edit?"
      assert @second_class.respond_to?(:can_delete?), "#{@second_class} doesn't respond to can_delete?"
    end
  end
  
end
