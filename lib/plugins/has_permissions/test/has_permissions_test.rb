require File.dirname(__FILE__) + '/helper'

class HasPermissionsTest < Test::Unit::TestCase
  
  context "An instance of a class in with we call the method 'has_permissions'" do
    setup do
      ActiveRecord::Base.connection.create_table :firsts do |t|
        t.string :column1
      end
      
      @object = First.new
      @user = User.first
    end
    
    teardown do 
      ActiveRecord::Base.connection.drop_table :firsts
    end
    
    should "respond to the methods can_*?" do
      assert @object.respond_to?(:can_view?), "#{@object} doesn't respond to can_view?"
      assert @object.respond_to?(:can_list?), "#{@object} doesn't respond to can_list?"
      assert @object.respond_to?(:can_add?), "#{@object} doesn't respond to can_add?"
      assert @object.respond_to?(:can_edit?), "#{@object} doesn't respond to can_edit?"
      assert @object.respond_to?(:can_delete?), "#{@object} doesn't respond to can_delete?"
    end
  end
  
  context "A class in with we call the method 'has_permissions :as_business_object'" do
    setup do
      ActiveRecord::Base.connection.create_table :seconds do |t|
        t.string :column1
      end
      
      @object = Second
      @user = User.first
    end
    
    teardown do
      ActiveRecord::Base.connection.drop_table :seconds
    end
    
    should "respond to the methods can_*?" do
      assert @object.respond_to?(:can_view?), "#{@object} doesn't respond to can_view?"
      assert @object.respond_to?(:can_list?), "#{@object} doesn't respond to can_list?"
      assert @object.respond_to?(:can_add?), "#{@object} doesn't respond to can_add?"
      assert @object.respond_to?(:can_edit?), "#{@object} doesn't respond to can_edit?"
      assert @object.respond_to?(:can_delete?), "#{@object} doesn't respond to can_delete?"
    end
  end
  
end
