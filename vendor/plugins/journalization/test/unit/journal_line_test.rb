#  journalization  Copyright (C) 2010  Ronnie Heritiana RABENANDRASANA (http://github.com/rOnnie974)
#
#  Contributor: Mathieu FONTAINE aka spidou (http://github.com/spidou)
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program. If not, see <http://www.gnu.org/licenses/>.

require File.dirname(__FILE__) + '/../test_helper.rb'

class JournalLineTest < ActiveRecordTestCase
  should_belong_to :journal, :referenced_journal
  
  should_validate_presence_of :journal
  
  context "A new journal line," do
    setup do 
      @line = JournalLine.new
    end
    
    ["old_value", "new_value"].each do |method|
      context "when setting #{method} to nil," do
        setup do
          @line.send("#{method}=", nil)
        end
        
        should "have #{method} returning nil" do
          assert_nil @line.send(method)
        end
      end    
      
      context "when setting #{method} to ''," do
        setup do
          @line.send("#{method}=", "")
        end
        
        should "have #{method} returning nil" do
          assert_nil @line.send(method)
        end
      end
      
      a_bignum   = 123456789 * 987654321 * 123456789 * 987654321
      a_date     = "2010-09-17"
      a_time     = "Fri Sep 17 11:13:20 +0400 2010"
      a_datetime = "2010-09-17T11:14:13+04:00"
      
      fixtures = {"true"                           => [ "boolean",      TrueClass,  true                                         ], 
                  "false"                          => [ "boolean",      FalseClass, false                                        ],
                  "1"                              => [ "integer",      Fixnum,     1                                            ],
                  "#{a_bignum}"                    => [ "integer",      Bignum,     a_bignum                                     ],
                  "1.5"                            => [ "float",        Float,      1.5                                          ],
                  "1.23"                           => [ "decimal",      BigDecimal, BigDecimal.new("1.23")                       ],
                  a_date                           => [ "date",         Date,       a_date.to_date                               ],
                  a_time                           => [ "time",         Time,       a_time .to_time                              ],
                  a_datetime                       => [ "datetime",     DateTime,   a_datetime.to_datetime                       ],
                  "Rick Roll"                      => [ "string",       String,     "Rick Roll"                                  ],
                  [1,2,3].to_yaml                  => [ "serialized_array", Array,      [1,2,3]                                  ]}
      
      fixtures.each_pair do |value, types_and_return|
        common_type = types_and_return[0]
        ruby_type      = types_and_return[1]
        returned_value = types_and_return[2]
          
        context "when setting #{method} to #{value}," do
          setup do
            @line.send("#{method}=", value)
          end
          
          should "have #{method} returning '#{value}'" do
            assert_equal value, @line.send(method)
          end
          
          should "have #{method} class returning String}" do
            assert_equal String, @line.send(method).class
          end
          
          context "and property_type set to '#{common_type}'" do
            setup do
              @line.property_type = common_type
            end
            
            should "have #{method} returning #{returned_value}" do
              assert_equal returned_value, @line.send(method)
            end
            
            should "have #{method} class returning #{ruby_type}" do
              assert_equal ruby_type, @line.send(method).class
            end
          end
        end
      end
    end
  end
end
