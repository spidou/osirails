require File.dirname(__FILE__) + '/../rh_test'

class JobTest < ActiveSupport::TestCase
  def setup
    @job = jobs(:developer)
  end

  def test_uniqueness_of_name
    assert_no_difference 'Job.count' do
      job = Job.create(:name => @job.name)
      assert_not_nil job.errors.on(:name), "A Job should have an uniq name"
    end
  end
end
