require 'test_helper'

class IbanTest < ActiveSupport::TestCase
  def setup
    @iban = Iban.create :bank_name => "Bank",
                        :bank_code => "12345",
                        :branch_code => "12345",
                        :account_number => "12345678901",
                        :key => "12"
  end

  def test_read
    assert_nothing_raised "An Iban should be read" do
      Iban.find(@iban.id)
    end
  end

  def test_update
    assert @iban.update_attributes(:bank_name => 'new bank'), "An Iban should be update"
  end

  def test_delete
    assert_difference 'Iban.count', -1, "An Iban should be delete" do
      @iban.destroy
    end
  end

  def test_validity
    assert @iban.valid?, "This Iban should be valid"
  end

  def test_format_of_bank_code
    @iban.update_attributes(:bank_code => '1')
    assert_not_nil @iban.errors.on(:bank_code), "An Iban bank code should be compose by 5 integer"
  end

  def test_format_of_branch_code
    @iban.update_attributes(:branch_code => '1')
    assert_not_nil @iban.errors.on(:branch_code), "An Iban branch code should be compose by 5 integer"
  end

  def test_format_of_account_number
    @iban.update_attributes(:account_number => '1')
    assert_not_nil @iban.errors.on(:account_number), "An Iban account number should be compose by 11 integer"
  end

  def test_format_of_key
    @iban.update_attributes(:key => '1')
    assert_not_nil @iban.errors.on(:key), "An Iban key should be compose by 2 integer"
  end
end
