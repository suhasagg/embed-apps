class TaskGeneratorsController < ApplicationController
  before_filter :authenticate_user!

  def create
    gen_params = ActiveSupport::JSON.decode(params[:task_input])
    table_name = (0..10).map{|i| (65 +rand(26)).chr}.join("")
    rectangle  = gen_params["rectangle"]
    resolution = gen_params["resolution"]
    email = current_user.email
    GisTaskGenerator.perform_async(table_name,rectangle, resolution,email)
    render "show.html.erb"
  end
end