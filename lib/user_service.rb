require 'savon'
require 'rest_client'
require "addressable/uri"
class UserService
	def initialize
		@client = Savon.client(wsdl: "http://10.1.0.236:8088/HPUWebService.asmx?wsdl")
	end
	def client
		@client
	end
	def operations		
		@client.operations
	end
	def load_email(email)		
	    response = @client.call(:cau_hinh_mon_hoc_list_by_email, message: {email: email})
	    res_hash = response.body.to_hash
		ls = res_hash[:cau_hinh_mon_hoc_list_by_email_response][:cau_hinh_mon_hoc_list_by_email_result][:diffgram][:document_element]    	
    	return nil unless ls
    	return ls[:cau_hinh_mon_hoc]
	end
	def get_mon(ma_mon_hoc)
#		CauHinhMonHoc_GetByMaMonHoc
		response = @client.call(:cau_hinh_mon_hoc_get_by_ma_mon_hoc, message: {ma_mon_hoc: ma_mon_hoc})
	    res_hash = response.body.to_hash
		ls = res_hash[:cau_hinh_mon_hoc_get_by_ma_mon_hoc_response][:cau_hinh_mon_hoc_get_by_ma_mon_hoc_result][:diffgram][:document_element]
    	return ls[:cau_hinh_mon_hoc]
	end
	def update(message)
		response = @client.call(:cau_hinh_mon_hoc_update, message: message)
	    res_hash = response.body.to_hash
	    ls = res_hash[:cau_hinh_mon_hoc_update_response][:cau_hinh_mon_hoc_update_result]
    	return ls    	
	end
	def change_password(user, oldp, newp)
		if user.password == oldp
			user.password = newp
			user.save!
			return 1
		else
			return 0
		end
	end
	def update_status(message)
		response = @client.call(:cau_hinh_mon_hoc_update_status, message: message)
	    res_hash = response.body.to_hash
	    ls = res_hash[:cau_hinh_mon_hoc_update_status_response][:cau_hinh_mon_hoc_update_status_result]
    	return ls
	end
end