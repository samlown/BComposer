class RecipientMetaOption < ActiveRecord::Base

  validates_uniqueness_of :value, :scope => [:field, :project_group_id]

end
