class MainController < Sinatra::Base
  register Sinatra::ActiveRecordExtension	
  set :sessions => true
  set :database_file, "config/database.yml"
  set :root, Proc.new {File.expand_path(".",Dir.pwd)}
  set :views, Proc.new { File.join(root, "views") }
  register do
    def auth (type)
      condition do
        redirect "/login" unless send("is_#{type}?")
      end
    end
  end

  helpers do
    def is_user?
      @user != nil
    end
  end

  before do
    if session[:user_id]
      @user = User.find(session[:user_id])
    else
      @user = nil
    end
  end

  get "/" do
    "Hello, anonymous."
  end

  get "/protected", :auth => :user do
    "Hello, #{@user.username}."
  end

  get "/login" do 
  	erb :login, :layout => :layout
  end

  post "/login" do
    session[:user_id] = User.where(username: params[:username],password: params[:password]).first.id
    redirect "/protected"
  end

  get "/logout" do
    session[:user_id] = nil
  end
end

