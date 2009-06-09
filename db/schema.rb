# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20081217153653) do

  create_table "bulletin_layouts", :force => true do |t|
    t.integer  "bulletin_id",               :default => 0,  :null => false
    t.string   "name",        :limit => 30, :default => "", :null => false
    t.string   "filetype",    :limit => 20, :default => "", :null => false
    t.string   "charset",     :limit => 20, :default => "", :null => false
    t.text     "rendered",                  :default => "", :null => false
    t.datetime "updated_on"
  end

  add_index "bulletin_layouts", ["bulletin_id", "name"], :name => "bulletin_id_name", :unique => true

  create_table "bulletins", :force => true do |t|
    t.integer  "project_id",                 :default => 0,   :null => false
    t.integer  "templet_id",                 :default => 0,   :null => false
    t.string   "title",                      :default => "",  :null => false
    t.string   "subject"
    t.text     "notes"
    t.text     "rendered"
    t.string   "status",        :limit => 1, :default => "O", :null => false
    t.datetime "date_released"
    t.datetime "updated_on"
    t.text     "filter_raw"
    t.date     "date"
    t.integer  "sent_count",                 :default => 0
    t.integer  "fail_count",                 :default => 0
    t.text     "stats_data"
  end

  create_table "content_page_tags", :id => false, :force => true do |t|
    t.integer "content_page_id", :null => false
    t.integer "tag_id",          :null => false
  end

  create_table "content_pages", :force => true do |t|
    t.integer  "templet_id",                                :null => false
    t.string   "name",                                      :null => false
    t.string   "status",      :limit => 1, :default => "O", :null => false
    t.text     "abstract"
    t.text     "content"
    t.text     "notes"
    t.datetime "created_on",                                :null => false
    t.datetime "updated_on",                                :null => false
    t.string   "media_url"
    t.integer  "bulletin_id"
  end

  create_table "entries", :force => true do |t|
    t.integer  "section_id",               :default => 0,  :null => false
    t.text     "title",                    :default => "", :null => false
    t.text     "subtitle"
    t.string   "style",      :limit => 50
    t.text     "body"
    t.string   "image_link"
    t.text     "image_text"
    t.string   "link"
    t.string   "link_text"
    t.integer  "position",   :limit => 6,  :default => 0,  :null => false
    t.datetime "created_on",                               :null => false
    t.datetime "updated_on"
  end

  create_table "project_groups", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_on"
  end

  create_table "projects", :force => true do |t|
    t.string   "name",              :limit => 50,  :default => "", :null => false
    t.string   "sender",            :limit => 100, :default => "", :null => false
    t.text     "report_recipients"
    t.string   "domain"
    t.text     "description"
    t.string   "default_lang",      :limit => 3,   :default => "", :null => false
    t.datetime "updated_on"
    t.integer  "project_group_id",                 :default => 1
  end

  create_table "recipient_email_receipts", :id => false, :force => true do |t|
    t.integer  "bulletin_id",               :default => 0, :null => false
    t.integer  "recipient_id",              :default => 0, :null => false
    t.string   "status",       :limit => 1
    t.datetime "received"
  end

  add_index "recipient_email_receipts", ["bulletin_id", "recipient_id"], :name => "bulletin_recipient_id"

  create_table "recipient_meta_options", :force => true do |t|
    t.integer  "project_group_id"
    t.integer  "parent_id"
    t.string   "field"
    t.string   "value"
    t.datetime "created_on"
    t.datetime "updated_on"
  end

  add_index "recipient_meta_options", ["field", "project_group_id"], :name => "index_recipient_meta_options_on_field_and_project_group_id", :unique => true

  create_table "recipient_receipts", :force => true do |t|
    t.integer  "bulletin_id",               :default => 0, :null => false
    t.integer  "recipient_id",              :default => 0, :null => false
    t.string   "status",       :limit => 1
    t.datetime "received"
    t.datetime "read"
    t.integer  "hits",                      :default => 0, :null => false
  end

  add_index "recipient_receipts", ["bulletin_id", "recipient_id"], :name => "bulletin_id"

  create_table "recipients", :force => true do |t|
    t.string   "email",                           :default => "",    :null => false
    t.string   "firstname",        :limit => 128
    t.string   "surname",          :limit => 64
    t.string   "surname2",         :limit => 64
    t.string   "lang_pref",        :limit => 3,   :default => "ES",  :null => false
    t.datetime "created_on",                                         :null => false
    t.datetime "updated_on"
    t.text     "new_data"
    t.integer  "project_group_id",                :default => 1
    t.boolean  "confirmed_real",                  :default => false
  end

  create_table "sections", :force => true do |t|
    t.integer  "bulletin_id",               :default => 0,  :null => false
    t.string   "name",                      :default => "", :null => false
    t.text     "title"
    t.string   "style",       :limit => 50
    t.text     "description"
    t.string   "type",        :limit => 10
    t.string   "link"
    t.string   "link_text"
    t.datetime "created_on",                                :null => false
    t.datetime "updated_on"
  end

  create_table "subscriptions", :force => true do |t|
    t.integer  "recipient_id",              :default => 0, :null => false
    t.integer  "project_id",                :default => 0, :null => false
    t.string   "state",        :limit => 1
    t.string   "confirm_code"
    t.datetime "created_on"
    t.datetime "updated_on"
  end

  add_index "subscriptions", ["recipient_id", "project_id"], :name => "subscription_id"

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_on"
  end

  create_table "templet_layouts", :force => true do |t|
    t.integer  "templet_id",                :default => 0,           :null => false
    t.string   "name",        :limit => 30, :default => "",          :null => false
    t.string   "filetype",    :limit => 20, :default => "text/html", :null => false
    t.string   "charset",     :limit => 20, :default => "UTF-8",     :null => false
    t.boolean  "edit_as_raw",               :default => false,       :null => false
    t.text     "data",                      :default => "",          :null => false
    t.datetime "created_on",                                         :null => false
    t.datetime "updated_on"
    t.string   "filter",      :limit => 20
  end

  create_table "templets", :force => true do |t|
    t.integer  "project_id",                :default => 0,     :null => false
    t.string   "type",        :limit => 24
    t.string   "type_code",   :limit => 1,  :default => "B",   :null => false
    t.string   "name",        :limit => 50, :default => "",    :null => false
    t.string   "subject"
    t.boolean  "static",                    :default => false, :null => false
    t.text     "description",               :default => "",    :null => false
    t.datetime "created_on",                                   :null => false
    t.datetime "updated_on"
  end

  create_table "user_roles", :force => true do |t|
    t.integer  "user_id",                            :null => false
    t.integer  "project_id",                         :null => false
    t.boolean  "edit_project",    :default => false, :null => false
    t.boolean  "create_bulletin", :default => false, :null => false
    t.boolean  "send_bulletin",   :default => false, :null => false
    t.boolean  "edit_bulletin",   :default => false, :null => false
    t.boolean  "edit_recipients", :default => false, :null => false
    t.boolean  "edit_section",    :default => false, :null => false
    t.boolean  "edit_entry",      :default => false, :null => false
    t.boolean  "edit_templates",  :default => false, :null => false
    t.datetime "created_on",                         :null => false
    t.datetime "updated_on"
    t.boolean  "edit_pages",      :default => false, :null => false
    t.boolean  "edit_files",      :default => false, :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "password_hash"
    t.text     "description"
    t.boolean  "admin_role",    :default => false
    t.datetime "created_on"
    t.datetime "date_update"
  end

end
