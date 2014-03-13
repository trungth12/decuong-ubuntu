class User 	< ActiveRecord::Base
		
	def self.authenticate(u, p)
		User.where(username: u, password: p).first
	end

	def self.get(id)
		return nil unless id
		User.find(id)
	end
end