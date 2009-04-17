require 'test_helper'

class CommodityTest < ActiveSupport::TestCase
  def setup
    @commodity_category = CommodityCategory.create(:name => 'test')
    @commodity = Commodity.create(:name => "Galva 1500x3000x2",
                                  :fob_unit_price => "26.88",
                                  :taxe_coefficient => "0",
                                  :measure => "4.50", :unit_mass => "70.65",
                                  :commodity_category_id => @commodity_category.id)
  end

  def test_read
    assert_nothing_raised "A Commodity should be read" do
      Commodity.find_by_name("Galva 1500x3000x2")
    end
  end

  def test_update
    assert @commodity.update_attributes(:name => 'test update'), "A Commotidy should be update"
  end

  def test_delete
    assert_difference 'Commodity.count', -1 do
      @commodity.destroy
    end
  end

  def test_presence_of_commodity_category_id
    assert_no_difference 'Commodity.count' do
      commodity = Commodity.create
      assert_not_nil commodity.errors.on(:commodity_category_id), "A Commodity should have a commodity category id"
    end
  end

  def test_presence_of_name
    assert_no_difference 'Commodity.count' do
      commodity = Commodity.create
      assert_not_nil commodity.errors.on(:name), "A Commodity should have a name"
    end
  end

  def test_presence_of_fob_unit_price
    assert_no_difference 'Commodity.count' do
      commodity = Commodity.create
      assert_not_nil commodity.errors.on(:fob_unit_price), "A Commodity should have a fob unit price"
    end
  end

  def test_presence_of_unit_mass
    assert_no_difference 'Commodity.count' do
      commodity = Commodity.create
      assert_not_nil commodity.errors.on(:unit_mass), "A Commodity should have a unit mass"
    end
  end

  def test_presence_of_measure
    assert_no_difference 'Commodity.count' do
      commodity = Commodity.create
      assert_not_nil commodity.errors.on(:measure), "A Commodity should have a measure"
    end
  end

  def test_presence_of_taxe_coefficient
    assert_no_difference 'Commodity.count' do
      commodity = Commodity.create
      assert_not_nil commodity.errors.on(:taxe_coefficient), "A Commodity should have a taxe coefficient"
    end
  end

  def test_numericality_of_fob_unit_price
    assert_no_difference 'Commodity.count' do
      commodity = Commodity.create(:fob_unit_price => 'a')
      assert_not_nil commodity.errors.on(:fob_unit_price), "A Commodity fob unit price should be numeric"
    end
  end

  def test_numericality_of_unit_mass
    assert_no_difference 'Commodity.count' do
      commodity = Commodity.create(:unit_mass => 'a')
      assert_not_nil commodity.errors.on(:unit_mass), "A Commodity unit mass should be numeric"
    end
  end

  def test_numericality_of_measure
    assert_no_difference 'Commodity.count' do
      commodity = Commodity.create(:measure => 'a')
      assert_not_nil commodity.errors.on(:measure), "A Commodity measure should be numeric"
    end
  end

  def test_numericality_of_taxe_coefficient
    assert_no_difference 'Commodity.count' do
      commodity = Commodity.create(:taxe_coefficient => 'a')
      assert_not_nil commodity.errors.on(:taxe_coefficient), "A Commodity taxe coefficient should be numeric"
    end
  end

  def test_commodity_category
    assert_equal @commodity.commodity_category, @commodity_category, "A Commodity should have a category"
  end
end