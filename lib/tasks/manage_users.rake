#
# = Save and Load the default templets
# 
# Used during development and modifications of the default templets
# which are stored in the database.
# 
# Custom YAML and rhtml files are used to store and load the templets
# based on their names (not IDs!)
#
# == Saving Templets
# 
# Templets are stored int he db/templets directory with the lowercase
# name of the templet as both .yml and .rhtml files. The YAML describes
# basic name and description information, and the rhtml file contains
# the actual templet.
# 
# == Loading Templets
# 
# This will always overwrite the default templets. Any project specific 
# templets will not be effected.
#

namespace :users do
  desc "Add a new admin user with a default password if one does not already exist."
  task :add_admin_user => :environment do
    # try to find an old one
    user = User.find_by_name('admin')
    if ! user
      # Add an admin user!
      user = User.new( :name => 'admin',
        :password => 'admin', :password_confirmation => 'admin' )
      user.admin_role = true
      if user.save
        puts "Administration user created!"
        puts "  User: admin   Password: admin"
      else
        puts "Unable to create admin user!"
        puts $!
      end
    else
      puts "An administration use already exists!"
    end
  end
  
  desc "Reset the admin user's password. If no admin user exists, no change will be made."
  task :reset_admin_password => :environment do
    user = User.find_by_name('admin')
    if ! user
      puts "No Admin user found! Run rake users:add_admin_user to create one!"
    else
      user.password = 'admin'
      user.password_confirmation = 'admin'
      if user.save
        puts "Administration user password reset to 'admin' successfully."
      else
        puts "Something went wrong, no password has been changed."
      end
    end
  end
end
