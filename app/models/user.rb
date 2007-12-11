
require 'digest/sha1'

class User < ActiveRecord::Base
  # empty project used for administrator!
  # belongs_to :project
  has_many :user_roles, :dependent => :destroy
  has_many :projects, :through => :user_roles
  
  attr_protected :id
  
  attr_accessor :password, :password_confirmation
  
  validates_length_of :name, :within => 3..20
  validates_length_of :password, :within => 5..20, :if => Proc.new { |user| ! user.password.nil? }
  validates_presence_of :name
  validates_presence_of :password, :password_confirmation, :on => :create
  validates_uniqueness_of :name
  validates_confirmation_of :password
  
  def self.authenticate(login, pass)
    u = find(:first, :conditions=>["name = ?", login])
    return nil if u.nil?
    return u if User.encrypt(pass) == u.password_hash
    nil
  end  
  
  def password=(pass)
    @password = pass
    self.password_hash = User.encrypt(@password)
  end         

  # tell us if the user is an admin
  def is_admin?
    admin_role
  end
  
   
  protected

  def self.encrypt(pass)
    Digest::SHA1.hexdigest(pass + "FO==22m.sj1")
  end

end
