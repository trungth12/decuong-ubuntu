#encoding: utf-8
require 'json'
class MainController < Sinatra::Base
  register Sinatra::ActiveRecordExtension	
  set :sessions => true
  set :database_file, "config/database.yml"
  set :erb, :format => :html5
  set :root, Proc.new {File.expand_path(".",Dir.pwd)}
  set :views, Proc.new { File.join(root, "views") }
  set :public_folder, Proc.new { File.join(root, "public") }
  def user_service
    @user_service || (@user_service = UserService.new)
  end
  register do
    def auth (type)
      condition do
        redirect "/login" unless session[:user_id]
      end
    end
  end
  register Sinatra::Flash
  helpers do
    def is_user?
      user != nil
    end
    def user
      @user || (@user= User.find(session[:user_id]) if session[:user_id]) 
    end
    def hinh_thuc_thi(res1)
      x = %w[B.Vệ BTL BVPM PM TH TL Đài TNG TNPM VĐ]      
      x.inject(""){|res, elem| res + "<label class='checkbox-inline'>
  <input #{'checked' if res1.include?(elem)} name='hinh_thuc_thi[]' type='checkbox' value='#{elem}'>#{elem}
</label>"}
    end
    def loai_mon_hoc(res1)
      x = ['Chuyên đề', 'Đồ án môn học', 'Khóa luận tốt nghiệp', 'Kỹ năng', 'Lý thuyết', 'Thực hành', 'Thực tập tốt nghiệp', 'Thực tế môn học']
      x.inject(""){|res, elem| res + "<label class='checkbox-inline'>
  <input #{'checked' if res1.include?(elem)} name='loai_mon_hoc[]' type='checkbox' value='#{elem}'>#{elem}
</label>"}
    end
    def de_cuong_xay_dung_theo_huong(res1)
      x = ['Chuẩn AUN-QA', 'Bộ GDĐT', 'Tự học (30/70)']
      x.inject(""){|res, elem| res + "<label class='checkbox-inline'>
  <input #{'checked' if res1.include?(elem)} name='de_cuong_xay_dung_theo_huong[]' type='checkbox' value='#{elem}'>#{elem}
</label>"}
    end
  end
  
  after do    
    p params
  end
  get "/", :auth => :user do    
    @danh_sach_mons = user_service.load_email(user.username)
    erb :index, :layout => :application
  end

  get "/show/:ma_mon_hoc", :auth => :user do 
    @ma_mon_hoc = params[:ma_mon_hoc]
    @mon = Mon.where(ma_mon_hoc: @ma_mon_hoc).first_or_create!
    @res = user_service.get_mon(@ma_mon_hoc)
    @loai_mon_hoc = @res[:loai_mon_hoc] || "Lý thuyết"
    @hinh_thuc_thi = @res[:hinh_thuc_thi] || "B.Vệ"
    @de_cuong_xay_dung_theo_huong = @res[:de_cuong_xay_dung_theo_huong] || "Bộ GDĐT"
    erb :show, :layout => :application
  end
  
 

  post "/update/:ma_mon_hoc", :auth => :user do     
    if params[:action] == "x"
      @mon = Mon.where(ma_mon_hoc: params[:ma_mon_hoc]).first
      @mon.file.remove!
      flash[:success] = "Bạn đã xóa thành công" unless @mon.file?
      redirect "/show/#{params[:ma_mon_hoc]}"
    else
      @message = {
        :user_name => 'hpuws',
        :password =>  'yb2NqJPWYEq2Y9VyTZcpvg==',
        :ma_mon_hoc => params[:ma_mon_hoc],
        :loai_mon_hoc => params[:loai_mon_hoc].join(","),
        :de_cuong_xay_dung_theo_huong => params[:de_cuong_xay_dung_theo_huong].join(","),
        :hinh_thuc_thi => params[:hinh_thuc_thi].join(","),
        :thoi_gian_thi => params[:thoi_gian_thi].to_i,
        :tong_so_tiet => params[:tong_so_tiet].to_i,
        :so_tiet_ly_thuyet => params[:so_tiet_ly_thuyet].to_i,
        :so_tiet_thuc_hanh => params[:so_tiet_thuc_hanh].to_i,
        :so_tiet_tu_hoc => params[:so_tiet_tu_hoc].to_i,
        :so_tiet_bai_tap => params[:so_tiet_bai_tap].to_i,
        :so_tiet_di_thuc_te => params[:so_tiet_di_thuc_te].to_i,      
        :ty_le_diem_qua_trinh => params[:ty_le_diem_qua_trinh],
        :de_cuong_chi_tiet => ""
      }
      @res = user_service.update(@message)
      @mon = Mon.where(ma_mon_hoc: params[:ma_mon_hoc]).first_or_create!
      @mon.file = params[:file]
      @mon.save
      #erb :update, :layout => :application
      flash[:success] = "Bạn đã cập nhật thành công" if @res.to_i == 1    
      redirect "/show/#{params[:ma_mon_hoc]}"
    #erb :update, :layout => :application
    end
  end

  get "/de_cuong_chi_tiet/:ma_mon_hoc?.pdf?" do 
    mon = Mon.where(ma_mon_hoc: params[:ma_mon_hoc]).first
    if mon
      File.open(mon.file.file.path) do |f|
        send_file(f, :disposition => 'attachment', :filename => File.basename(f))
      end
    else
      erb :error, :layout => :application
    end
  end

  post "/update_status/:ma_mon_hoc" do
    message = {
      :user_name => 'hpuws',
      :password =>  'yb2NqJPWYEq2Y9VyTZcpvg==',
      :ma_mon_hoc => params[:ma_mon_hoc],
      :dang_bi_khoa => true
    }
    @res = user_service.update_status(message)
    if @res.to_i == 1
      flash[:success] = "Cập nhật thành công"
    else
      flash[:error] = "Có lỗi xảy ra, vui lòng thử lại"
    end
    redirect "/"
  end

  get "/login" do 
  	erb :login, :layout => :application
  end

  post "/login" do
    user = User.where(username: params[:username],password: params[:password]).first
    if user
      session[:user_id] = user.id    
    else
      flash[:error] = "Tài khoản không đúng, vui lòng đăng nhập lại"
      redirect "/login"
    end
    redirect "/"
  end

  get "/logout" do
    session[:user_id] = nil
    redirect "/"
  end

  get "/profile", :auth => :user do 
    erb :profile, :layout => :application
  end

  post "/profile", :auth => :user do 
    @res = user_service.change_password(user, params[:oldpassword], params[:newpassword])
    if @res == 1
      flash[:success] = "Bạn đã cập nhật mật khẩu thành công"
    else
      flash[:error] = "Mật khẩu cũ không đúng"
    end
    redirect "/profile"
  end
end

