class ApplicationController < ActionController::Base
  #protect_from_forgery
  helper_method :current_or_guest_username

  private
  def stored_location_for(resource_or_scope)
    nil
  end

  def after_sign_in_path_for(resource_or_scope)
     apps_path
  end

  protected

  # if user is logged in, return current_user, else return guest_user
  # guest_user used only to save results
  # to display results in anonymous mode , we do not save the user
  # but set a value inside a cookie
  def current_or_guest_user
    if current_user
      current_user
    else
      guest_user
    end
  end

  def current_or_guest_username
    if current_user
      cookies[:guest_user] = ""
      current_user.username
    else
      guest_username
    end
  end

  #use only the cookie to store the current user
  def guest_username
    if cookies[:guest_user].blank?
      o = [(0..9), ('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
      random = (0..6).map { o[rand(o.length)] }.join
      cookies[:guest_user] = "guest_#{random}"
    end
    #we override if mturk
    cookies[:guest_user] = params[:workerId] unless params[:workerId].blank?
    cookies[:guest_user]
  end

  # find guest_user
  # creating one if needed
  def guest_user
    User.find_by_username(guest_username) || create_guest_user(guest_username)
  end

  private

  def create_guest_user(username)
    User.create(:username => username, :email => "#{username}@emailguest.com",:password=>"guest_user", :anonymous=>true)
  end

end
