require 'test/test_helper'

class ServiceTest < ActiveSupport::TestCase
  fixtures :services
  
  def setup
    @parent = services(:parent)
    @child = services(:child)
    @child.update_attributes(:parent => @parent)
  end
  
  def test_create
    assert_difference 'Service.count', +1, "A Service should be created" do
      service = Service.create(:name => 'test service')
    end
  end
  
  def test_read
    assert_nothing_raised "A Service should be read" do
      Service.find_by_name(@parent.name)
    end
  end
  
  def test_update
    assert @parent.update_attributes(:name => 'new_name'), "A Service should be updated"
  end
  
  def test_delete
    assert_difference 'Service.count', -1 do
      @child.destroy
    end
  end
  
  def test_recursive_delete
    parent_id = @parent.id
    @parent.destroy
    assert_equal [], Service.find_all_by_service_parent_id(parent_id), "destroying a parent service should destroy all its children at the same time"
  end
  
  def test_parent_of_a_service
    assert_equal @parent.children, [@child], "This service should have a child service"
  end
  
  def test_child_of_a_service
    assert_equal @child.parent, @parent, "This service should have a parent service"
  end
  
  def test_presence_of_name
    assert_no_difference 'Service.count' do
       service = Service.create(:name => '')
       assert_not_nil service.errors.on(:name), "A Service should not have a blank name"
     end
  end
end
