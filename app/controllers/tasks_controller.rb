class TasksController < ApplicationController

  before_filter :get_app

  def index
    render :json => @app.tasks
  end

  # POST /tasks.json
  def create
    data  = ActiveSupport::JSON.decode(params[:data])
    @task = @app.add_task(data)
    render :json => task, :status => created, :location => @task
  end

  def show
    task = @app.tasks.where(:input_task_id => params[:id])
    render :json => task.to_json, :callback => params[:callback]
  end

  def next
    context = {
      :from_task => params[:from_task],
      :current_username => current_or_guest_username
    }
    task = @app.next_task(context)
    if task.nil?
      render :json => {:error => "no task found"}, :status => 404
    else
      redirect_to(app_task_url(@app,task))
    end
  end

  protected

  def get_app
    @app = App.find(params[:app_id])
  end
end
