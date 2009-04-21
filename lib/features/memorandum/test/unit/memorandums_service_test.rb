require 'test_helper'

class MemorandumsServiceTest < ActiveSupport::TestCase
  fixtures :memorandums_services, :services, :memorandums

  def setup
    @memorandums_service = memorandums_services(:normal)
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
    assert_equal @memorandums_service.service, services(:parent),
      "This MemorandumsService should belongs to this Service"
  end

  def test_belongs_to_memorandum
    assert_equal @memorandums_service.memorandum, memorandums(:normal),
      "This MemorandumsService should belongs to this Memorandum"
  end
end