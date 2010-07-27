require File.dirname(__FILE__) + '/../memorandum_test'

class MemorandumsServiceTest < ActiveSupport::TestCase
  def setup
    @memorandums_service = memorandums_services(:first_memorandum_direction_general)
  end

  def test_presence_of_service_id
    assert_no_difference 'MemorandumsService.count' do
      memorandums_service = MemorandumsService.create
      assert_not_nil memorandums_service.errors.on(:service_id), "A MemorandumsService should have a service id"
    end
  end

  def test_presence_of_memorandum_id
    assert_no_difference 'MemorandumsService.count' do
      memorandums_service = MemorandumsService.create
      assert_not_nil memorandums_service.errors.on(:memorandum_id), "A MemorandumsService should have a memorandum id"
    end
  end

  def test_belongs_to_service
    assert_equal @memorandums_service.service, services(:direction_general),
      "This MemorandumsService should belongs to this Service"
  end

  def test_belongs_to_memorandum
    assert_equal @memorandums_service.memorandum, memorandums(:first_memorandum),
      "This MemorandumsService should belongs to this Memorandum"
  end
end
