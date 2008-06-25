class Recipient < ActiveRecord::Base
  
  belongs_to :project_group
  
  has_many :recipient_receipts, :dependent => :delete_all

  has_many :subscriptions, :dependent => :delete_all
  has_many :projects, :through => :subscriptions

  attr_protected :id
  
  validates_associated :project_group
  
  validates_uniqueness_of :email, :scope => :project_group_id, :message => _("- address is already in the database.")
  
  validates_presence_of :email, :message => _("- address required.")
  # validates_presence_of :password, :message => "required!"
  
  validates_format_of :email, :with => /^([\d\w][\d\w\+\.\-\_]*)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, 
            :message => _("- invalid address");
  

  def full_name
    str = ""
    if (self.firstname)
      str += self.firstname
      str += ' ' + surname if (surname)
      str += ' ' + surname2 if (surname2)
    elsif (self.surname)
      str += surname
      str += ' ' + surname2 if (surname2)
    end
    str
  end

  def safe_method?( method )
    return true if attribute_names.include? method
    return true if ['full_name'].include? method    
  end
 
  def stats_url( bulletin )
    if ! self.new_record?
      fname = Base64::encode64( Marshal::dump( [self.id, bulletin.id] ) ).chomp
      url = bulletin.project.domain + '/stats/add/' + fname + '.png'
      return url
    end
  end
  
end
