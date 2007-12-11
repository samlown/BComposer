class ProjectGroup < ActiveRecord::Base
  has_many :projects, :dependent => :destroy
  has_many :recipients, :dependent => :delete_all
  
  # Do not allow the default to be deleted!
  def destroy
    if (self.id == 1 or self.name == 'Default')
      return false
    end
    super()
  end
end
