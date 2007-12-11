module LibraryHelper

  def self.check_magick
    begin
      return true if not Magick.nil?
    rescue
      # no magic here!
    end
    return false
  end
end
