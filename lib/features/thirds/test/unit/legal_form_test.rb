require 'test_helper'

class LegalFormTest < ActiveSupport::TestCase
  def test_presence_of_name
    assert_no_difference 'LegalForm.count' do
      legal_form = LegalForm.create
      assert_not_nil legal_form.errors.on(:name), "A LegalForm should have a name"
    end
  end
end
