require File.dirname(__FILE__) + '/../thirds_test'

class ThirdTest < ActiveSupport::TestCase
  should_belong_to :legal_form
  
  should_validate_presence_of :name
  
  should_allow_values_for :website, nil, "", "website.fr", "www.website.com", "foo.website.com", "website.com/url", "website.com/complex/url"
  should_not_allow_values_for :website, "http://www.website.com", "website", "website.", ".website", "website.a", "foo/website.com"
end
