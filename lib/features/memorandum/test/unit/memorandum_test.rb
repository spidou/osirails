require 'test_helper'

class MemorandumTest < ActiveSupport::TestCase
  def setup
    @memorandum = Memorandum.create(:title => 'Service note',
                                    :subject => 'Foooo',
                                    :text => 'bar',
                                    :signature => 'The Boss',
                                    :user_id => 3,
                                    :published_at => Time.now - 3.months)
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
  
  def test_memorandum_service
    # TODO
  end
end
