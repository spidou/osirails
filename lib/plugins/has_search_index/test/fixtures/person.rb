class Person < ActiveRecord::Base
  belongs_to :gender
  
   ################# N-N ##################
   
  # N-N through polymorphic
  has_many :people_wishes, :as => :has_wishes
  has_many :wishes, :through => :people_wishes
  
  # N-N through
  has_many :relationships
  has_many :friends, :class_name => 'Person', :through => :relationships
  
  # N-N
  has_and_belongs_to_many :favorite_colors
  
   ################# 1-1 ##################
   
  # 1-1 through polymorphic
  has_one :people_dream, :as => :has_dream
  has_one :dream, :through => :people_dream
  
  # 1-1 through
  has_one :familly_relationship
  has_one :love, :class_name => 'Person', :through => :familly_relationship
  
  # 1-1 polymorphic
  has_one :identity_card, :as => :has_identity_card
  
  # 1-1 
  has_one :dog

   ################# 1-N ##################
   
  # 1-N polymorphic
  has_many :numbers, :as => :has_number

  # 1-N
  has_many :summer_jobs
end
