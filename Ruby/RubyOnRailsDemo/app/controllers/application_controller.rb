class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def new
  end

  def create
	p "666666"*10
	#返回请求内容
	render plain: params[:article].inspect
  end  
  
  
  
end
