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

require File.join(File.dirname(__FILE__), 'test_helper')

class JournalizationTest < ActiveRecordTestCase
  context "With District journalizing its name only," do
    setup do
      District.journalize :attributes => :name
    end
    
    teardown do
      District.journalized_attributes = []
    end
    
    context "a new district" do
      setup do
        @dupark = District.new
      end
      
      should "not contain any journals" do
        assert_equal [], @dupark.journals
      end
      
      should "NOT have journal_identifier" do
        assert_nil @dupark.journal_identifier
      end
    end
    
    context "a newly created district" do
      setup do
        @dupark = District.new(:name => "Dupark", :area => 1000)
        flunk "@dupark must be saved to perform the next test" unless @dupark.save
      end
      
      should "have a last_journal corresponding to its newly created journal" do
        assert_equal @dupark.journals.last, @dupark.last_journal
      end
      
      should "have an only one journal for its creation" do
        assert_equal 1, @dupark.journals.count
      end
    
      should "have a journal with an only one line" do
        assert_equal 1, @dupark.journals.first.journal_lines.count
      end
      
      should "have a journal with lines including one which property is \"name\", old_value is nil and new_value is its new name" do
        assert_not_nil @dupark.journals.first.journal_lines.detect { |l| l.property == "name" && l.old_value.nil? && l.new_value == @dupark.name}
      end
      
      should "have a journal without associated journal_identifier" do
        assert_nil @dupark.journals.first.journal_identifier
      end
      
      context "after an update of its name, Person acting on journalization, and @a_person (Person) being the journalization actor, @dupark" do
        setup do
          create_a_person
          
          Person.acts_on_journalization_with :name   
          Person.journalization_actor_object = @a_person         
          
          @dupark.name = "another name changed by a person"
          flunk "@dupark must be saved to perform the next test" unless @dupark.save
        end
        
        teardown do
          Person.reset_journalization_actor_object
          silence_warnings do
            Journalization.const_set("ActorClassName", nil)
          end
        end
        
        should "have a last journal with @a_person as actor" do
          assert_equal @a_person, @dupark.journals.last.actor
        end
      end
      
      3.times do |idx|
        idx += 1
        context "after an update of both its name and area #{idx != 1 ? 'for the ' + idx.ordinalize + ' time' : ''}" do
          setup do
            @dupark_old_name = @dupark.last_journalized_value_for("name")
            @dupark.name     = "another name #{idx}"
            @dupark.area    += rand(1000)
            
            @dupark_journals_count = @dupark.journals.count 
            flunk "@dupark must be saved to perform the next test" unless @dupark.save
          end
          
          should "have an additional journal" do
            assert_equal 1, @dupark.journals.count - @dupark_journals_count
          end
          
          should "have an additional journal with only one line which property is \"name\", old_value is its previous name and new_value is its new name" do
            assert_equal 1, @dupark.journals.last.journal_lines.count
            first = @dupark.journals.last.journal_lines.first
            
            assert_equal "name", first.property
            assert_equal @dupark_old_name, first.old_value
            assert_equal @dupark.name, first.new_value
          end
        end
      end
      
      context "after an update of its area only" do
        setup do
          @dupark.area += rand(1000)
          
          @dupark_journals_count = @dupark.journals.count 
          flunk "@dupark must be saved to perform the next test" unless @dupark.save
        end
        
        should "NOT have any additional journal" do
          assert_equal 0, @dupark.journals.count - @dupark_journals_count
        end
      end
      
      context "with its class journalizing now area" do
        setup do
          District.journalize :attributes => :area
        end
        
        teardown do
          District.journalized_attributes = [:name]
        end
        
        context "after an update of both its name and area" do
          setup do
            @dupark_old_area = @dupark.last_journalized_value_for("area")
            @dupark.area    += rand(1000)
            @dupark.name     = "another name"
            
            @dupark_journals_count  = @dupark.journals.count 
            flunk "@dupark must be saved to perform the next test" unless @dupark.save
          end
          
          should "have an additional journal" do
            assert_equal 1, @dupark.journals.count - @dupark_journals_count
          end
          
          should "have an additional journal with two lines including one which property is \"area\", old_value is its previous area and new_value is its new area" do
            last_journal = @dupark.journals.last
          
            assert_equal 2, last_journal.journal_lines.count
            assert_not_nil last_journal.journal_lines.detect { |l| l.property == "area" && l.old_value.to_s == @dupark_old_area.to_s && l.new_value.to_s == @dupark.area.to_s }
          end
        end
      end
      
      context "with its class journalizing now an identifier using the `to_s` method" do
        setup do
          District.journalize :identifier_method => :to_s
        end
        
        teardown do
          District.journal_identifier_method = nil
        end
          
        context "after an update of its name" do
          setup do
            @dupark.name = "another name"
            flunk "@dupark must be saved to perform the next test" unless @dupark.save
          end
          
          should "have a journal_identifier old_value equals nil as it is the first" do
            assert_nil @dupark.journal_identifier.old_value
          end
          
          should "have a journal_identifier new_value equals to the result of the class identifier method" do
            assert_equal @dupark.send(@dupark.class.journal_identifier_method.to_s), @dupark.journal_identifier.new_value
          end
          
          should "have an additional journal with a journal identifier" do
            identifier = @dupark.journals.last.journal_identifier
            
            assert_equal @dupark.journal_identifier, identifier
          end
          
          context "and a destroy of itself" do
            setup do
              @dupark_old_journals            = @dupark.journals
              @dupark_old_journal_identifiers = @dupark.journal_identifiers
              @dupark_class_name              = @dupark.class.name
              @dupark_id                      = @dupark.id
              flunk "@dupark must be destroyed to perform the next test" unless @dupark.destroy
            end
            
            should "keep its journals thanks to the Journal.find_for method" do
              assert_equal @dupark_old_journals, Journal.find_for(@dupark_class_name, @dupark_id)
            end
            
            should "keep its identifiers thanks to the JournalIdentifier.find_for method" do
              assert_equal @dupark_old_journal_identifiers, JournalIdentifier.find_for(@dupark_class_name, @dupark_id)
            end
          end
          
          context "twice" do
            setup do
              @dupark_old_journal_identifier_value = @dupark.send(@dupark.class.journal_identifier_method.to_s)
              @dupark.name = "another name again"
              flunk "@dupark must be saved to perform the next test" unless @dupark.save
            end
            
            should "have a journal_identifier old_value equals to the result of the previous class identifier method" do
              assert_equal @dupark_old_journal_identifier_value, @dupark.journal_identifier.old_value
            end
            
            should "have a journal_identifier new_value equals to the result of the class identifier method" do
              assert_equal @dupark.send(@dupark.class.journal_identifier_method.to_s), @dupark.journal_identifier.new_value
            end
          
            should "have an additional journal with a journal identifier" do
              identifier = @dupark.journals.last.journal_identifier
              
              assert_equal @dupark.journal_identifier, identifier
            end
          end
          
          context "then changing its area only" do
            setup do
              @dupark_journals_count = @dupark.journals.count
              @dupark_old_journal_identifier = @dupark.journal_identifier
              @dupark.area += rand(1000)
              flunk "@dupark must be saved to perform the next test" unless @dupark.save
            end
            
            should "NOT have any additional journal" do
              assert_equal 0, @dupark.journals.count - @dupark_journals_count
            end
            
            should "keep the same journal identifier as before" do
              assert_equal @dupark_old_journal_identifier, @dupark.journal_identifier
            end
          end
        end
      end
    end
  end
  
  context "With Person journalizing its first_name, last_name and photo_file_name" do
    setup do
      Person.journalize :attributes => [:first_name, :last_name, :photo_file_name]
    end
    
    teardown do
      Person.journalized_attributes = []
    end
    
    context "a newly created person" do
      setup do
        create_a_person
      end
      
      should "have a last_journal corresponding to its newly created journal" do
        assert_equal @a_person.journals.last, @a_person.last_journal
      end
      
      should "have an only one journal for its creation" do
        assert_equal 1, @a_person.journals.count
      end
    
      should "have a journal with three lines" do
        assert_equal 3, @a_person.journals.first.journal_lines.count
      end
      
      should "have a journal with lines including one which property is \"first_name\", old_value is nil and new_value is its new first_name" do
        assert_not_nil @a_person.journals.first.journal_lines.detect { |l| l.property == "first_name" && l.old_value.nil? && l.new_value == @a_person.first_name}
      end
      
      should "have a journal with lines including one which property is \"last_name\", old_value is nil and new_value is its new last_name" do
        assert_not_nil @a_person.journals.first.journal_lines.detect { |l| l.property == "last_name" && l.old_value.nil? && l.new_value == @a_person.last_name}
      end
      
      should "have a journal with lines including one which property is \"photo_file_name\", old_value is nil and new_value is its new photo_file_name" do
        assert_not_nil @a_person.journals.first.journal_lines.detect { |l| l.property == "photo_file_name" && l.old_value.nil? && l.new_value == @a_person.photo_file_name}
      end
      
      should "have a journal without associated journal_identifier" do
        assert_nil @a_person.journals.first.journal_identifier
      end
      
      context "after an update of its photo and its class now journalizing photo as a paperclip attachment" do
        setup do
          Person.journalize :attachments => :photo
          
          @a_person_journals_count      = @a_person.journals.count
          @a_person_old_photo_file_name = @a_person.last_journalized_value_for("photo_file_name")
          @a_person_old_photo_file_size = @a_person.last_journalized_value_for("photo_file_size")
          
          @a_person.photo = File.new(File.join(File.dirname(__FILE__), "fixtures", "another_avatar.png"))
          flunk "@a_person must be saved to perform the next test" unless @a_person.save
        end
        
        teardown do
          Person.journalized_attachments = []
        end
        
        should "have an additional journal" do
          assert_equal 1, @a_person.journals.count - @a_person_journals_count
        end
        
        should "have an additional journal with two lines" do
          assert_equal 2, @a_person.journals.last.journal_lines.count
        end
        
        should "have an additional journal with a line which property is \"photo_file_name\", old_value is previous photo_file_name and new_value is its new photo_file_name" do
          assert_not_nil @a_person.journals.last.journal_lines.detect { |l| l.property == "photo_file_name" && l.old_value == @a_person_old_photo_file_name && l.new_value == @a_person.photo_file_name}
        end
        
        should "have an additional journal with a line which property is \"photo_file_size\", old_value is previous photo_file_size and new_value is its new photo_file_size" do
          assert_not_nil @a_person.journals.last.journal_lines.detect { |l| l.property == "photo_file_size" && l.old_value == @a_person_old_photo_file_size && l.new_value == @a_person.photo_file_size}
        end
        
      end
    end
  end
  
  context "In the @a_district environment with its representative" do
    setup do
      create_a_district_with_its_representative
    end
    
    context "when Person journalizes its first_name," do
      setup do
        Person.journalize :attributes => :first_name
      end
      
      teardown do
        Person.journalized_attributes = []
      end
      
      context "when District does not journalize its representative" do
        context "after an update of its representative first_name, @a_district" do
          setup do
            @a_district_representative_old_first_name = @a_district.representative.last_journalized_value_for("first_name")
            @a_district_representative_journals_count = @a_district.representative.journals.count
          
            @a_district.representative.first_name = "another first name"
            flunk "@a_district must be saved to perform the next test" unless @a_district.save
          end
          
          should "have its representative getting one additional journal" do
            assert_equal 1, @a_district.representative.journals.count - @a_district_representative_journals_count
          end
          
          should "have its representative getting one additional journal with an only one line which property is \"first_name\", old_value is @a_district representative old first name and new_value is @a_district representative first name}" do
            assert_not_nil @a_district.representative.journals.last.journal_lines.detect { |l| l.property == "first_name" && l.old_value == @a_district_representative_old_first_name && l.new_value == @a_district.representative.first_name}
          end
        end
      end
        
      context "when District journalizes its representative (with no restrictions)," do
        setup do
          District.journalize :subresources => [:representative]
          flunk "@a_district must be saved to perform the next test" unless @a_district.save
        end
        
        teardown do
          District.journalized_attributes = []
          District.journalized_subresources = {:has_many => {}, :has_one => {}}
        end
        
        context "after an update of its representative first_name, @a_district" do
          setup do
            @a_district_representative_old_first_name = @a_district.representative.last_journalized_value_for("first_name")
            @a_district_representative_journals_count = @a_district.representative.journals.count
            @a_district_journals_count = @a_district.journals.count
          
            @a_district.representative.first_name = "another first name"
            flunk "@a_district must be saved to perform the next test" unless @a_district.save
          end
          
          should "have its representative getting one additional journal" do
            assert_equal 1, @a_district.representative.journals.count - @a_district_representative_journals_count
          end
          
          should "have its representative getting one additional journal with an only one line which property is \"first_name\", old_value is @a_district representative old first name and new_value is @a_district representative first name}" do
            assert_not_nil @a_district.representative.journals.last.journal_lines.detect { |l| l.property == "first_name" && l.old_value == @a_district_representative_old_first_name && l.new_value == @a_district.representative.first_name}
          end
        
          should "have an additional journal" do
            assert_equal 1, @a_district.journals.count - @a_district_journals_count
          end
          
          should "have an additional journal with an only one line" do
            assert_equal 1, @a_district.journals.last.journal_lines.count
          end
          
          should "have an additional journal including one line referencing its representative update journal" do
            assert_not_nil @a_district.journals.last.journal_lines.detect {|l| l.property == "representative"                               && 
                                                                               l.old_value.nil?                                             && 
                                                                               l.new_value.nil?                                             &&
                                                                               l.property_id == @a_district.representative.id               &&
                                                                               l.referenced_journal == @a_district.representative.last_journal}
          end
          
          should "have one of its journal lines referenced in its representative update journal" do
            assert @a_district.journals.last.journal_lines.include?(@a_district.representative.last_journal.referenced_journal_line)
          end
        end
        
        context "after a change of person, @a_district" do
          setup do
            @a_district_journals_count = @a_district.journals.count
            @a_district_old_representative_id = @a_district.last_journalized_value_for("representative")
            create_a_person
            @a_district.representative = @a_person
            flunk "@a_district must be saved to perform the next test" unless @a_district.save
          end
        
          should "have an additional journal" do
            assert_equal 1, @a_district.journals.count - @a_district_journals_count
          end
          
          should "have an additional journal with two lines" do
            assert_equal 2, @a_district.journals.last.journal_lines.count
          end
          
          should "have an additional journal including one line referencing its change of person as representative" do
            assert_not_nil @a_district.journals.last.journal_lines.detect {|l| l.property == "representative"                               && 
                                                                               l.old_value.to_s == [@a_district_old_representative_id].to_s && 
                                                                               l.new_value.to_s == [@a_district.representative.id].to_s     &&
                                                                               l.property_id.nil?                                             }
          end
        end
        
        context "after a remove of the representative, @a_district" do
          setup do
            @a_district_journals_count = @a_district.journals.count
            @a_district_old_representative_id = @a_district.last_journalized_value_for("representative")
            @a_district.representative = nil
            flunk "@a_district must be saved to perform the next test" unless @a_district.save
          end
        
          should "have an additional journal" do
            assert_equal 1, @a_district.journals.count - @a_district_journals_count
          end
          
          should "have an additional journal with an only one line" do
            assert_equal 1, @a_district.journals.last.journal_lines.count
          end
          
          should "have an additional journal including one line referencing its remove of person as representative" do
            assert_not_nil @a_district.journals.last.journal_lines.detect {|l| l.property == "representative"                               && 
                                                                               l.old_value.to_s == [@a_district_old_representative_id].to_s && 
                                                                               l.new_value.to_s == [].to_s                                  &&
                                                                               l.property_id.nil?                                             }
          end
        end
        
        context "after a remove of the representative, then an addition of the representative, @a_district" do
          setup do
            @a_district.representative = nil
            flunk "@a_district must be saved to perform the next test" unless @a_district.save
            
            @a_district_journals_count = @a_district.journals.count
            @a_district_old_representative_id = @a_district.last_journalized_value_for("representative")
            @a_district.representative = create_a_person
            flunk "@a_district must be saved to perform the next test" unless @a_district.save
          end
        
          should "have an additional journal for the addition" do
            assert_equal 1, @a_district.journals.count - @a_district_journals_count
          end
          
          should "have an additional journal for the addition with two lines" do
            assert_equal 2, @a_district.journals.last.journal_lines.count
          end
          
          should "have an additional journal for the addition including one line referencing its addition of person as representative" do
            assert_not_nil @a_district.journals.last.journal_lines.detect {|l| l.property == "representative"                               && 
                                                                               l.old_value.to_s == [@a_district_old_representative_id].to_s && 
                                                                               l.new_value.to_s == [@a_district.representative.id].to_s     &&
                                                                               l.property_id.nil?                                             }
          end
        end
      end
      
      context "when District journalizes its representative (with the :update restriction)," do
        setup do
          District.journalize :subresources => [{:representative => :update}]
          flunk "@a_district must be saved to perform the next test" unless @a_district.save
        end
        
        teardown do
          District.journalized_attributes = []
          District.journalized_subresources = {:has_many => {}, :has_one => {}}
        end
        
        context "after an update of its representative first_name, @a_district" do
          setup do
            @a_district_representative_old_first_name = @a_district.representative.last_journalized_value_for("first_name")
            @a_district_representative_journals_count = @a_district.representative.journals.count
            @a_district_journals_count = @a_district.journals.count
          
            @a_district.representative.first_name = "another first name"
            flunk "@a_district must be saved to perform the next test" unless @a_district.save
          end
          
          should "have its representative getting one additional journal" do
            assert_equal 1, @a_district.representative.journals.count - @a_district_representative_journals_count
          end
          
          should "have its representative getting one additional journal with an only one line which property is \"first_name\", old_value is @a_district representative old first name and new_value is @a_district representative first name}" do
            assert_not_nil @a_district.representative.journals.last.journal_lines.detect { |l| l.property == "first_name" && l.old_value == @a_district_representative_old_first_name && l.new_value == @a_district.representative.first_name}
          end
        
          should "have an additional journal" do
            assert_equal 1, @a_district.journals.count - @a_district_journals_count
          end
          
          should "have an additional journal with an only one line" do
            assert_equal 1, @a_district.journals.last.journal_lines.count
          end
          
          should "have an additional journal including one line referencing its representative update journal" do
            assert_not_nil @a_district.journals.last.journal_lines.detect {|l| l.property == "representative"                               && 
                                                                               l.old_value.nil?                                             && 
                                                                               l.new_value.nil?                                             &&
                                                                               l.property_id == @a_district.representative.id               &&
                                                                               l.referenced_journal == @a_district.representative.last_journal}
          end
          
          should "have one of its journal lines referenced in its representative update journal" do
            assert @a_district.journals.last.journal_lines.include?(@a_district.representative.last_journal.referenced_journal_line)
          end
        end
        
        context "after a change of person, @a_district" do
          setup do
            @a_district_journals_count = @a_district.journals.count
            @a_district_old_representative_id = @a_district.last_journalized_value_for("representative")
            create_a_person
            @a_district.representative = @a_person
            flunk "@a_district must be saved to perform the next test" unless @a_district.save
          end
        
          should "have an additional journal" do
            assert_equal 1, @a_district.journals.count - @a_district_journals_count
          end
          
          should "have an additional journal with a line referencing its new representative journal creation" do
             assert_not_nil @a_district.journals.last.journal_lines.detect {|l| l.property == "representative"                               && 
                                                                                l.old_value.nil?                                             && 
                                                                                l.new_value.nil?                                             &&
                                                                                l.property_id == @a_district.representative.id               &&
                                                                                l.referenced_journal == @a_district.representative.last_journal}
          end
        end
        
        context "after a remove of the representative, @a_district" do
          setup do
            @a_district_journals_count = @a_district.journals.count
            @a_district_old_representative_id = @a_district.last_journalized_value_for("representative")
            @a_district.representative = nil
            flunk "@a_district must be saved to perform the next test" unless @a_district.save
          end
        
          should "have any additional journal" do
            assert_equal 0, @a_district.journals.count - @a_district_journals_count
          end
        end
      end
      
      context "when District journalizes its representative (with the :create_and_destroy)," do
        setup do
          District.journalize :subresources => [{:representative => :create_and_destroy}]
          flunk "@a_district must be saved to perform the next test" unless @a_district.save
        end
        
        teardown do
          District.journalized_attributes = []
          District.journalized_subresources = {:has_many => {}, :has_one => {}}
        end
        
        context "after an update of its representative first_name, @a_district" do
          setup do
            @a_district_representative_old_first_name = @a_district.representative.last_journalized_value_for("first_name")
            @a_district_representative_journals_count = @a_district.representative.journals.count
            @a_district_journals_count = @a_district.journals.count
          
            @a_district.representative.first_name = "another first name"
            flunk "@a_district must be saved to perform the next test" unless @a_district.save
          end
          
          should "have its representative getting one additional journal" do
            assert_equal 1, @a_district.representative.journals.count - @a_district_representative_journals_count
          end
          
          should "have its representative getting one additional journal with an only one line which property is \"first_name\", old_value is @a_district representative old first name and new_value is @a_district representative first name}" do
            assert_not_nil @a_district.representative.journals.last.journal_lines.detect { |l| l.property == "first_name" && l.old_value == @a_district_representative_old_first_name && l.new_value == @a_district.representative.first_name}
          end
        
          should "NOT have any additional journal" do
            assert_equal 0, @a_district.journals.count - @a_district_journals_count
          end
        end
        
        context "after a change of person, @a_district" do
          setup do
            @a_district_journals_count = @a_district.journals.count
            @a_district_old_representative_id = @a_district.last_journalized_value_for("representative")
            create_a_person
            @a_district.representative = @a_person
            flunk "@a_district must be saved to perform the next test" unless @a_district.save
          end
        
          should "have an additional journal" do
            assert_equal 1, @a_district.journals.count - @a_district_journals_count
          end
          
          should "have an additional journal with an only one line" do
            assert_equal 1, @a_district.journals.last.journal_lines.count
          end
          
          should "have an additional journal including one line referencing its change of person as representative" do
            assert_not_nil @a_district.journals.last.journal_lines.detect {|l| l.property == "representative"                               && 
                                                                               l.old_value.to_s == [@a_district_old_representative_id].to_s && 
                                                                               l.new_value.to_s == [@a_district.representative.id].to_s     &&
                                                                               l.property_id.nil?                                             }
          end
        end
        
        context "after a remove of the representative, @a_district" do
          setup do
            @a_district_journals_count = @a_district.journals.count
            @a_district_old_representative_id = @a_district.last_journalized_value_for("representative")
            @a_district.representative = nil
            flunk "@a_district must be saved to perform the next test" unless @a_district.save
          end
        
          should "have an additional journal" do
            assert_equal 1, @a_district.journals.count - @a_district_journals_count
          end
          
          should "have an additional journal with an only one line" do
            assert_equal 1, @a_district.journals.last.journal_lines.count
          end
          
          should "have an additional journal including one line referencing its remove of person as representative" do
            assert_not_nil @a_district.journals.last.journal_lines.detect {|l| l.property == "representative"                               && 
                                                                               l.old_value.to_s == [@a_district_old_representative_id].to_s && 
                                                                               l.new_value.to_s == [].to_s                                  &&
                                                                               l.property_id.nil?                                             }
          end
        end
        
        context "after a remove of the representative, then an addition of the representative, @a_district" do
          setup do
            @a_district.representative = nil
            flunk "@a_district must be saved to perform the next test" unless @a_district.save
            
            @a_district_journals_count = @a_district.journals.count
            @a_district_old_representative_id = @a_district.last_journalized_value_for("representative")
            @a_district.representative = create_a_person
            flunk "@a_district must be saved to perform the next test" unless @a_district.save
          end
        
          should "have an additional journal for the addition" do
            assert_equal 1, @a_district.journals.count - @a_district_journals_count
          end
          
          should "have an additional journal for the addition with an only one line" do
            assert_equal 1, @a_district.journals.last.journal_lines.count
          end
          
          should "have an additional journal for the addition including one line referencing its addition of person as representative" do
            assert_not_nil @a_district.journals.last.journal_lines.detect {|l| l.property == "representative"                               && 
                                                                               l.old_value.to_s == [@a_district_old_representative_id].to_s && 
                                                                               l.new_value.to_s == [@a_district.representative.id].to_s     &&
                                                                               l.property_id.nil?                                             }
          end
        end
      end
    end
  end
  
  context "In the @a_district environment with its representative when Person does not journalize anything" do
    setup do
      create_a_district_with_its_representative
    end
    
    context "when District journalizes its representative (with no restrictions)," do
      setup do
        District.journalize :subresources => [:representative]
        flunk "@a_district must be saved to perform the next test" unless @a_district.save
      end
      
      teardown do
        District.journalized_attributes = []
        District.journalized_subresources = {:has_many => {}, :has_one => {}}
      end
      
      context "after an update of its representative first_name, @a_district" do
        setup do
          @a_district_journals_count = @a_district.journals.count
        
          @a_district.representative.first_name = "another first name"
          flunk "@a_district must be saved to perform the next test" unless @a_district.save
        end
        
        should "NOT have any additional journal" do
          assert_equal 0, @a_district.journals.count - @a_district_journals_count
        end
      end
    end
  end
  
  context "In the @a_district environment with its schools and their teachers" do
    setup do
      create_a_district_with_its_schools_and_their_teachers
    end
    
    context "when District journalizes its schools, School journalizes its teachers and Person journalizes its first_name" do
      setup do
        District.journalize :subresources => [:schools]
        School.journalize   :subresources => [:teachers]
        Person.journalize   :attributes   => :first_name
      end
      
      teardown do
        District.journalized_subresources = {:has_one => {}, :has_many => {}}
        School.journalized_subresources   = {:has_one => {}, :has_many => {}}
        Person.journalized_attributes     = []
      end
  
      context "after an update of the first teacher first_name of the district first school, @district" do
        setup do
          @the_school  = @a_district.schools.first
          @the_teacher = @the_school.teachers.first
          
          #for the first journal
          flunk "@a_district must be saved to perform the next test"  unless @a_district.save
          flunk "@the_school must be saved to perform the next test"  unless @the_school.save
          flunk "@the_teacher must be saved to perform the next test" unless @the_teacher.save
          
          @a_district_old_journals_count   = @a_district.journals.count
          @the_school_old_journals_count  = @the_school.journals.count
          @the_teacher_old_journals_count = @the_teacher.journals.count
          
          @the_teacher_old_first_name = @the_teacher.first_name
          @the_school.should_update   = 1
          @the_teacher.should_update  = 1
          @the_teacher.first_name     = "Another-teacher-first-name"
          
          flunk "@a_district must be saved to perform the next test" unless @a_district.save
        end
        
        should "have the first teacher of its first school getting an additional journal" do
          assert_equal 1, @the_teacher.journals.count - @the_teacher_old_journals_count
        end
        
        should "have the first teacher of its first school getting an additional journal with a line which property is \"first_name\", old_value is the previous first name and new_value is the first name" do
          assert_not_nil @the_teacher.journals.last.journal_lines.detect {|l| l.property  == "first_name"                 && 
                                                                              l.old_value == @the_teacher_old_first_name  && 
                                                                              l.new_value == @the_teacher.first_name       }
        end
        
        should "have its first school getting an additional journal" do
          assert_equal 1, @the_school.journals.count - @the_school_old_journals_count
        end
        
        should "have its first school getting an additional journal with a line referencing its first teacher last journal" do
          assert_not_nil @the_school.journals.last.journal_lines.detect {|l| l.property == "teachers"                        && 
                                                                             l.old_value.nil?                                && 
                                                                             l.new_value.nil?                                &&
                                                                             l.property_id == @the_teacher.id                &&
                                                                             l.referenced_journal == @the_teacher.last_journal}
        end
        
        should "have an additional journal" do
          assert_equal 1, @a_district.journals.count - @a_district_old_journals_count
        end
        
        should "have an additional journal with a line referencing its first school last journal" do
          assert_not_nil @a_district.journals.last.journal_lines.detect {|l| l.property == "schools"                        && 
                                                                             l.old_value.nil?                               && 
                                                                             l.new_value.nil?                               &&
                                                                             l.property_id == @the_school.id                &&
                                                                             l.referenced_journal == @the_school.last_journal}
        end
      end
    end
  end
end
