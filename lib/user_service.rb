class UserService
	def initialize
		@client = Savon.client(wsdl: "http://10.1.0.238:8082/HPUWebService.asmx?wsdl")
	end
	def client
		@client
	end
	def operations		
		@client.operations
	end
	def load_email(email)		
	    response = @client.call(:cau_hinh_mon_hoc_get_by_email, message: {email: email})
	    res_hash = response.body.to_hash
		ls = res_hash[:cau_hinh_mon_hoc_get_by_email_response][:cau_hinh_mon_hoc_get_by_email_result][:diffgram][:document_element]
    	return ls[:cau_hinh_mon_hoc]
	end
end