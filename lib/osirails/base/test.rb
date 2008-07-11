# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

module Osirails
  module Base
    class Test < Feature
      @@name = "Test"
      @@version = "0.1"
      @@dependencies = []
      @@conflicts = []
      @@class_name = self.name
      
      def initialize
        super
        puts @@class_name
        puts @@name
        puts "toto"
      end
    end
  end
end
