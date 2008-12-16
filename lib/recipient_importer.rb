#
# Provide a set of functions to allow email addresses to be imported 
# into BComposer.
#

require 'fastercsv'

module RecipientImporter
  
  # Read the provided file as CSV and go through each line.
  # 
  # The status of entry is printed to the stdout, unless a code
  # block is provided in which case a message is provided as a 
  # variable to be displayed as desired.
  # 
  # Options
  #  :col_sep   => default is ','
  #  :row_sep   => default is automatic
  # 
  def self.import_from_csv( file, project, options = {} )
    
    # reset counters
    skipped_count = 0
    success_count = 0
    
    # check all okay
    raise "File does not exist!" if ! FileTest.exists? file
    raise "Invalid project, or no project group!" if ! project.project_group_id
    
    options.update( :headers => :first_row, :return_headers => true )
    if (! options[:col_sep])
      options[:col_sep] = ','
    end
  
    headers_correct = false
  
    FasterCSV.foreach( file, options ) do | row |
      if row.header_row?
        # check that all the headers are correct
        row.headers.each do | header |
          if not Recipient.column_names.include? header
            raise "Invalid Header! '"+header+"' is not a valid Recipient field."
          elsif ['id', 'state'].include? header
            raise "Invalid Header! '"+header+"' can not be included in imports."
          end
        end
        headers_correct = true
        next
      end
      raise "Headers have not been loaded correctly!" if ! headers_correct
  
      # start the hard work
      r = Recipient.new
      r.project_group_id = project.project_group_id
      row.each do | field, value |
        r.send(field+'=', value.strip)
      end
      # check to see if already exists
      r2 = Recipient.find_by_email( r.email )
      if r2.nil?
        r.save
      else
        r = r2
      end
      
      if ! r.errors.empty?
        skipped_count += 1
        msg = "Invalid entry: " + r.email
        if block_given? 
          yield msg
        else 
          puts msg
        end
        r.errors.each do | item, msg_set |
          msg_set = [ msg_set ] if ! msg_set.is_a? Array
          msg_set.each do | msg |
            msg = " * " + item + msg
            if block_given? 
              yield msg
            else 
              puts msg
            end
          end
        end
      else
        # now add link to project
        s = project.subscriptions.create(:recipient_id => r.id, :state => 'F' )
        if (! s.errors.empty?)
          skipped_count += 1
          msg = "Invalid entry: #{r.email}\n * Error adding subscription - probably a duplicate"
        else
          success_count += 1
          msg = "Added: #{r.email}"
        end

        if block_given?
          yield msg
        else 
          puts msg
        end
      end
    end
    
    return {:success => success_count, :skipped => skipped_count}
  end

end
