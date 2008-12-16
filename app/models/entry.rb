class Entry < ActiveRecord::Base
  belongs_to :section

  acts_as_list :scope => :section_id

  # Create a new entry and fill in all the required fields automatically.
  # This is required if the section is going to be saved before the
  # user has added any data.
  # 
  # Requires a section.
  def self.new_empty(section)
    e = Entry.new
    e.section = section
    e.set_defaults
    return e
  end
  
  def set_defaults
    self.title = "Entry Title"
    self.body = "Entry body text"
  end
end
