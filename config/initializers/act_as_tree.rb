module ActiveRecord
  module Acts
    module Tree
      module InstanceMethods
        # Method to get a structured +model+ list (where +model+ implements +acts_as_tree+)
        # return +self+ if there's no childrens
        # return a Hash like { +self+ => ARRAY }
        # -> ARRAY is a deep structured array (containing childrens and children's children ...)
        #
        # ==== example
        # 
        # model0
        #  \_ model1
        #     \_ model2
        #     \_ model3
        #  \_ model4
        #
        # model0.get_structured_childrens
        # #=> [model0 , [ [model1 , [model2, model3]], model4 ] ]
        #
        def get_structured_children
          if self.children.empty?
            return self
          else
            children_list = []
            list          = []
            self.children.each do |child|
              children_list << child.get_structured_children
            end
            return [ self, children_list ]
          end
        end
        
      end
    end
  end
end
