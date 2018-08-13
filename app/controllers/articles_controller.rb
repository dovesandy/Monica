class ArticlesController < ApplicationController
	
	def new
	
	end
	
	#创建
	def create
		render plain: params[:article].inspect	
	end
	
end
