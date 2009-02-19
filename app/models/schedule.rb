class Schedule < ActiveRecord::Base
  belongs_to :service

  def get_day
  end
end
