class AnswersController < ApplicationController

  # (used only for debugging)
  def index
    answers=App.find(params[:app_id]).answers.order("updated_at desc").limit(30)
    render :json=> answers.to_json
  end

  def update
    answer = Answer.find(params[:id] || params[:answer_id]) #put + get
    create_or_update(answer)
  end

  def create
    answer = Answer.new
    answer.task = Task.where( :app_id => params[:app_id] ).where( :input_task_id => params[:task_id] ).first
    create_or_update(answer)
  end

  private

  def get_answer
    @answer = Answer.find(params[:id] || params[:answer_id])
  end

  protected

  def create_or_update(answer)
    answer.user = current_or_guest_user
    answer.state = Answer::STATE[:COMPLETED]
    answer.input_from_form(params[:rows])
    current_or_guest_user.save  #change the updated date
    if answer.save
      app = answer.task.app
      if Rails.env == "production"
        FtSyncAnswers.perform_async(app.id) #we wait
      else
        app.sync_answers() #right now
      end
      flash[:success] = 'Answer was successfully created.'
      render :json => answer.to_json, :callback => params[:callback]
    else
      logger.error("answer #{answer.id} not saved for microapp #{answer.task.app.name} ");
      render :json => {:error => answer.errors}, :status => :unprocessable_entity, :location => nil
    end
  end

end

