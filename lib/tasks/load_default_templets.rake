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

namespace :db do
  desc "Loads the default templets from the source files and stores them in the database"
  task :load_default_templets => :environment do
    #unless ENV['TABLE']
    #  raise "Please specify a table via the TABLE environment variable"
    #end
    TempletExporter.load_and_store_templets
  end

  desc "Save all the current default templets to disk"
  task :save_default_templets => :environment do
    TempletExporter.save_templets
  end

end