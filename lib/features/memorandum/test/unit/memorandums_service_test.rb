require 'test_helper'

class MemorandumsServiceTest < ActiveSupport::TestCase
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
end