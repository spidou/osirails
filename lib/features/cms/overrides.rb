ContextualMenuManager::ContextualSection::SECTION_TITLES.merge!({ :content_history => "Historique" })

require_dependency 'menu'

class Menu
  has_one :content

  def can_has_this_parent?(new_parent_id)
    return true if new_parent_id.blank?
    new_parent = Menu.find(new_parent_id)
    return false if new_parent.id == self.id or new_parent.ancestors.include?(self) or !new_parent.content.nil?
    true
  end
end
