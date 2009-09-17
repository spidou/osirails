module ContextualMenuManager
  
  class ContextualMenu
    attr_accessor :sections
    
    def initialize
      @sections = []
    end
    
    def add_item(section, force_not_list, item)
      return if item.blank?
      new_item = ContextualItem.new(item)
      
      if @sections.collect(&:title).include?(section)
        @sections.each do |s|
          if s.title == section
            s.items << new_item
          end
        end
      else
        @sections << ContextualSection.new(section, !force_not_list, [ new_item ] )
      end
    end
  end
  
  class ContextualSection
    SECTION_TITLES = { :contextual_search => "Recherche Contextuelle",
                         :possible_actions  => "Actions Possibles",
                         :useful_links      => "Liens Utiles" }
    
    attr_accessor :title, :items, :list_mode
    
    def initialize(title, display_list = true, items = [])
      @title = title
      @items = items
      @display_list = display_list
    end
    
    def title=(symbol)
      @title = symbol
    end
    
    def title
      @title
    end
    
    def list?
      @display_list
    end
    
    def to_s
      SECTION_TITLES[@title] || @title.to_s.humanize
    end
    
  end
  
  class ContextualItem
    attr_accessor :content
    
    def initialize(content)
      @content = content
    end
  end
  
end
