require 'test/test_helper'

class MemorandumTest < ActiveSupport::TestCase
  fixtures :memorandums, :memorandums_services, :services, :users

  def setup
    @memorandum = memorandums(:normal)
  end

  def test_read
    assert_nothing_raised "A Memorandum should be read" do
      Memorandum.find_by_title(@memorandum.title)
    end
  end

  def test_update
    assert @memorandum.update_attributes(:title => 'new title')
  end

  def test_delete
    assert_difference 'Memorandum.count', -1 do
      @memorandum.destroy
    end
  end

  def test_presence_of_title
    assert_no_difference 'Memorandum.count' do
      memorandum = Memorandum.create
      assert_not_nil memorandum.errors.on(:title), "A Memorandum should have a title"
    end
  end

  def test_presence_of_subject
    assert_no_difference 'Memorandum.count' do
      memorandum = Memorandum.create
      assert_not_nil memorandum.errors.on(:subject), "A Memorandum should have a subject"
    end
  end

  def test_presence_of_text
    assert_no_difference 'Memorandum.count' do
      memorandum = Memorandum.create
      assert_not_nil memorandum.errors.on(:text), "A Memorandum should have a text"
    end
  end

  def test_presence_of_signature
    assert_no_difference 'Memorandum.count' do
      memorandum = Memorandum.create
      assert_not_nil memorandum.errors.on(:signature), "A Memorandum should have a signature"
    end
  end

  def test_find_by_services
    assert_equal Memorandum.find_by_services([services(:parent)]), [@memorandum]
  end

  def test_has_many_memorandum_service
    assert_equal @memorandum.memorandums_services, [memorandums_services(:normal)],
      "This Memorandum should have this MemorandumsService"
  end

  def test_has_many_services
    assert_equal @memorandum.services, [services(:parent)],
      "This Memorandum should have this service"
  end

  def test_belongs_to_user
    assert_equal @memorandum.user, users(:powerful_user),
      "This Memorandum should belongs to this User"
  end
end
