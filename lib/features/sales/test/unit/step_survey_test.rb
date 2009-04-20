require 'test_helper'

class StepSurveyTest < ActiveSupport::TestCase
  def test_presence_of_commercial_id
    assert_no_difference 'StepSurvey.count' do
      step_survey = StepSurvey.create
      assert_not_nil step_survey.errors.on(:commercial_id),
        "A StepSurvey should have a commercial id"
    end
  end
end
