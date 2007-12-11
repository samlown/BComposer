class Section < ActiveRecord::Base
  belongs_to :bulletin
  has_many :entries, :order => 'position', :dependent => :destroy
  
  # Create a new section and fill in all the required fields automatically.
  # This is required if the section is going to be saved before the
  # user has added any data.
  # 
  # Requires the parent bulletin and name.
  def self.new_empty(bulletin, name)
    s = Section.new
    s.bulletin = bulletin
    s.name = name
    s.set_defaults
    return s
  end
  
  def set_defaults
    self.title = "New Section "+self.name
    self.date_created = Time.now
    self.date_updated = Time.now
  end
  
  def move_up_entry( entry )
    # ensure order is correct!
    self.reorder_entries
    # swap the entries  
    k = entry.position
    self.entries(true).each do | e |
      if (e.position == (k - 1))
        e.position = k
        entry.position = k - 1
        e.save
        entry.save
        break
      end
    end
  end
  
  def move_down_entry( entry )
    # ensure order is correct!
    self.reorder_entries
    # swap the entries  
    k = entry.position
    self.entries(true).each do | e |
      if (e.position == (k + 1))
        e.position = k
        entry.position = k + 1
        e.save
        entry.save
        break
      end      
    end
  end
  
  protected
  
  #
  # Go through each entry and check the order.
  # If the entries do not have a position, give them one
  # 
  def reorder_entries
    i = 1
    self.entries.each do | e |
      if (e.position != i)
         e.position = i
         e.save
      end
      i += 1
    end
  end
  
end
