require 'test/test_helper'

# TODO find a simple way to use a fixture in place of a real model to test that override.
# That test suite should be run with a generic model like a fixture to permit to test the plugin's override
#   regardless to the implementing model.
#
# For the moment the test is based onto +Menu+ model and if it no longer implements the plugin, then the test will
#   become useless.
#
# So if you still want to base the test onto real model, Well keep in mind that you must test the plugin using a model
#   currently implementing the plugin in order to pass this test.
#
class ActAsTreeOverrideTest < ActiveSupport::TestCase
  def setup
    @model = Menu # configure here the model you want to use to test the override
    flunk "the model #{@model} doesn't implements the plugin 'act_as_tree'" unless @model.new.respond_to?('children')
  end
  
  def teardown
    @model = nil
  end
  
  
  # the following test use that hierachy:
  #
  # root
  #  \_ child1
  #     \_ child2
  #     \_ child3
  #  \_ child4
  #      
  def test_get_structured_children
    (root   = @model.new).save(false) # save whitout validation because model's validity is not the goal here
    (child1 = @model.new(:parent_id => root.id)).save(false)
    (child2 = @model.new(:parent_id => child1.id)).save(false)
    (child3 = @model.new(:parent_id => child1.id)).save(false)
    (child4 = @model.new(:parent_id => root.id)).save(false)
    message = "Returned Array should be as expected"
    
    # from root
    expected_array = [root, [[child1, [child2, child3]], child4 ]] 
     assert_equal expected_array, root.get_structured_children, message
     
    # from child1
    expected_array = [child1, [child2, child3]]
     assert_equal expected_array, child1.get_structured_children, message
     
    # from child4
    expected_array = child4
       assert_equal expected_array, child4.get_structured_children, message
  end
end
