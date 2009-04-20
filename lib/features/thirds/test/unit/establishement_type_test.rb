require 'test_helper'

class EstablishmentTypeTest < ActiveSupport::TestCase
  def test_presence_of_name
    assert_no_difference 'EstablishmentType.count' do
      establishment_type = EstablishmentType.create
      assert_not_nil establishment_type.errors.on(:name),
        "An EstablishmentType should have a name"
    end
  end
end
