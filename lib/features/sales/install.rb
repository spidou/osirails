## Checklist Example
# step = Step.find_by_name("parent_step")
# c = Checklist.create(:name => "Question 1")
# c.step = step
# c.save
# c = Checklist.create(:name => "Question 2")
# c.checklistoptions << ChecklistOption.create(:name => "Options 1")
# c.checklistoptions << ChecklistOption.create(:name => "Options 2")
# c.step = step
# c.save