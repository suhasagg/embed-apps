class AppsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index,:create_gf_table, :stats, :show, :embed, :source]
  before_filter :get_app, :except => [:index, :new, :create, :create_gf_table]
  before_filter :redirect_unless_owner, :except => [:index, :stats, :show, :new, :create_gf_table, :create, :embed, :source]


  def index
    @apps = App.order("created_at asc")
  end

  def show
  end

  def embed
    render :layout => false
  end

  def new
    unless params[:copyof].blank?
      @app = App.find(params[:copyof]).clone
      @cloned = true
    else
      @app = App.new
      @cloned = false
    end
  end

  # POST /apps
  # POST /apps.json
  def create
    params[:app][:user_id] = current_user.id
    @app = App.create(params[:app])
    if @app.save
      redirect_to source_app_path(@app), notice: 'app was successfully created.'
    else
      render :new
    end
  end

  def stats
      respond_to do |format|
        format.html {}
        format.json {
          stats = {
            :opened => @app.tasks.not_done_by_username(current_or_guest_username).count,
            :completed => @app.tasks.done_by_username(current_or_guest_username).count
          }
          render :json => stats, :callback => params[:callback]
        }
end
  end

  def action
    @app.send(params[:method])
    redirect_to app_path(@app), notice: 'Reindexing tasks'
  end

  def create_gf_table
    ft_id = case params[:table]
    when "answers"
      FtDao.create_answers_table(current_user.email)
    when "tasks"
      FtDao.create_challenges_table(current_user.email)
    end
    render :json => {:ft_table_id => ft_id}.to_json
  end

  def source
    redirect_to @app.gist_url unless @owner
  end

  def source_update
    if @app.update_attributes(params[:app])
       @app.upload_source_code
      render json: {"gist_id" => @app.gist_id}.to_json
    else
      render json: @app.errors, status: :unprocessable_entity
    end
  end

  # GET /apps/1/edit
  def edit
  end


  # PUT /apps/1
  # PUT /apps/1.json
  def update

    if @app.update_attributes(params[:app])
      respond_to do |format|
        format.html {
          redirect_to app_path(@app), notice: 'app was successfully updated.'
        }
        format.json { render :nothing => true}
      end
    else
      respond_to do |format|
        format.html { render action: "edit" }
        format.json { render json: @app.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /apps/1
  # DELETE /apps/1.json
  def destroy
    @app.destroy
    redirect_to apps_url, notice: 'app was successfully deleted.'
  end

  private

  def get_app
    @app = App.find(params[:id])
    @owner = (current_user == @app.user)? true : false
  end


  def redirect_unless_owner
    redirect_to root_url unless current_user == @app.user
  end

end
