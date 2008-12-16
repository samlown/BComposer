class Project < ActiveRecord::Base

  belongs_to :project_group

  has_many :bulletins, :dependent => :destroy
  has_many :user_roles, :dependent => :destroy
  has_many :users, :through => :user_roles
  
  has_many :subscriptions, :dependent => :delete_all
  has_many :valid_subscriptions, :class_name => 'Subscription',
      :conditions => Subscription.valid_filter, :include => :recipient
  has_many :recipients, :through => :subscriptions
  has_many :valid_recipients, :through => :subscriptions, :source => :recipient, 
      :conditions => Subscription.valid_filter
  
  has_many :templets, :dependent => :destroy do
    def find_by_name( pname )
      Templet.find(:first,
        :conditions => ['name = ? AND (project_id = 0 OR project_id = ?)', pname, proxy_owner.id ],
        :order => 'project_id DESC')
    end
    def find_for_bulletin
      Templet.find_for_bulletin( proxy_owner )
    end
  end

  # Provide a the domain along with the project name
  # which is the correct way to set the base project location.
  def full_domain
    self.domain + '/' + self.name.gsub(/ /, '+')
  end
  
  #
  # Provide a directory path where this project 
  # stores all its files.
  # 
  # Each file associated with a project is stored in the /public/projects/id_name directory,
  # where "id_name" is a the id of the project along with its name. Only the ID part is used
  # internally, the name is for human value only.
  # 
  def directory_path
    return @directory_path if @directory_path
  
    basedir = "project_files/"
    
    found = false
    
    Dir.entries('public/'+basedir).each do | file |
      next if (! FileTest.directory?( 'public/'+basedir + file ))
      if file.to_i == self.id
        basedir += file
        found = true
        break
      end
    end
    
    if ! found
      basedir += self.id.to_s + '_' + self.name.downcase.gsub(/[^a-z0-9_]/, '_')
      Dir.mkdir('public/'+basedir)
    end
    @directory_url = '/' + basedir
    @directory_path = 'public/' + basedir
  end

  def directory
    return @directory if @directory
    @directory = Dir.new(directory_path)
  end
  
  def directory_url
    @directory_url if self.directory_path
  end
  
  def safe_method?( method )
    return true if attribute_names.include? method
    return true if ['full_domain'].include? method
  end
end
