class HomeController < ApplicationController

  def index
    @app=App.where("name LIKE ?", "%urbanism%").first
    @app=App.order("random()").first if (@app.nil?)
    render :layout => false
  end

  def more
    render :layout=>"application"
  end

end
