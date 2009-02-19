class ContentVersion < ActiveRecord::Base

  # Relationship
  belongs_to :content
  belongs_to :contributor, :class_name => "User"

  # Callbacks
  before_create :time_to_versioned_at

  def self.create_from_content(content)
    self.create(:title          => content.title,
    :description    => content.description,
    :text           => content.text,
    :menu_id        => content.menu_id,
    :content_id     => content.id,
    :contributor_id => (content.contributors.empty? ? content.author : content.contributors[content.contributors.size - 2]))
  end

  # This method permit to attribute a value to versioned_at
  def updated_at=(value)
    self.versioned_at = value
  end

  # This method permit to attribute a value to contributor
  def contributors=(value)
    self.contributor=(value)
  end

  # This method permit to unset create_at
  def created_at=(value)
    false
  end

  # This method permit to unset author
  def author=(value)
    false
  end

  # This method permit to unset lock_version
  def lock_version=(value)
    false
  end

  private

  def time_to_versioned_at
    self.versioned_at = Time.now
  end
end
