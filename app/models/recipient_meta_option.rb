class RecipientMetaOption < ActiveRecord::Base

  acts_as_tree
  
  belongs_to :project_group
  
  validates_uniqueness_of :value, :scope => [:field, :project_group_id]
  validates_presence_of :value
  
  validates_presence_of :field
  
  
end
