require 'test_helper'

class ServiceTest < ActiveSupport::TestCase
  fixtures :services
  
  def setup
    @parent_service = services(:parent)
    @child_service = services(:child)
    @child_service.update_attributes(:parent_service => @parent_service)
  end
  
  def test_create
    assert_difference 'Service.count', +1, "A Service should be created" do
      service = Service.create(:name => 'test service')
    end
  end
  
  def test_read
    assert_nothing_raised "A Service should be read" do
      Service.find_by_name(@parent_service.name)
    end
  end
  
  def test_update
    assert @parent_service.update_attributes(:name => 'new_name'), "A Service should be updated"
  end
  
  def test_delete
    assert_difference 'Service.count', -1 do
      @child_service.destroy
    end
  end
  
  def test_recursive_delete
    parent_service_id = @parent_service.id
    @parent_service.destroy
    assert_equal [], Service.find_all_by_service_parent_id(parent_service_id), "A Service who are parent should destroy his children if he is destroyed"
  end
  
  def test_parent_of_a_service
    assert_equal @parent_service.children, [@child_service], "This service should have a child service"
  end
  
  def test_child_of_a_service
    assert_equal @child_service.parent_service, @parent_service, "This service should have a parent service"
  end
  
  def test_prescence_of_name
    assert_no_difference 'Service.count' do
       service = Service.create(:name => '')
       assert_not_nil service.errors.on(:name), "A Service should not have a blank name"
     end
  end
end