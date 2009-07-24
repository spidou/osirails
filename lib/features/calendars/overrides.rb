ContextualMenuManager::ContextualSection::SECTION_TITLES.merge!({ :calendar => "Calendrier" })

require_dependency 'user'

class User 
  has_one :calendar
end
