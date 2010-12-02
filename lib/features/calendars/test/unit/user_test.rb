require File.dirname(__FILE__) + '/../calendars_test'

class UserTest < ActiveSupport::TestCase
  should_have_one :calendar
  
  context "Creating a user" do
    setup do
      @count_calendars_before = Calendar.count
      @user = User.create! :username => "john.doe", :password => "my password"
    end
    
    should "have succesfully created a calendar" do
      assert_equal @count_calendars_before + 1, Calendar.count
    end
    
    should "have created a calendar with valid name" do
      assert_equal "Calendrier de john.doe", @user.calendar.name
    end
    
    should "have created a calendar with valid title" do
      assert_equal "Calendrier de john.doe", @user.calendar.title
    end
    
    should "have an associated calendar" do
      assert_not_nil @user.calendar
    end
  end
end
