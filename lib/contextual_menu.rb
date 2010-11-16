module Osirails
  module ContextualMenu
    
    class ContextualMenu
      attr_accessor :sections
      
      def initialize
        @sections = []
      end
      
      def add_item(section, force_not_list, position, item)
        return if item.blank?
        new_item = Item.new(item)
        
        if @sections.collect(&:title).include?(section)
          @sections.each do |s|
            if s.title == section
              s.items << new_item
            end
          end
        else
          section = Section.new(section, !force_not_list, [ new_item ] )
          
          if position == :first || position.to_i < 0
            @sections.unshift(section)
          elsif position == :last || position.to_i >= @sections.size
            @sections.push(section)
          else
            @sections.insert(position.to_i, section)
          end
        end
      end
    end
    
    class Section
      @@section_titles ||= {  :contextual_search => "Recherche Contextuelle",
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
        @@section_titles[@title] || @title.to_s.humanize
      end
      
    end
    
    class Item
      attr_accessor :content
      
      def initialize(content)
        @content = content
      end
    end
    
  end
end
