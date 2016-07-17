require 'carrierwave/orm/activerecord'
require_relative './my_uploader'
class Mon < ActiveRecord::Base
	mount_uploader :file, MyUploader
	def file_url
		"/download/#{self.id}"
	end
end

