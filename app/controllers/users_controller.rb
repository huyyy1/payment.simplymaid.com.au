class UsersController < ApplicationController

  before_action :authenticate_user!

  def index
    if current_user.is_admin
      @users = User.order('created_at DESC').all
    else
      redirect_to weeks_path, alert: "Not allowed"
    end
  end

  def new
    if current_user.is_admin
      @user = User.new
    else
      redirect_to weeks_path, alert: "Not allowed"
    end
  end

  def create
    if current_user.is_admin
      @user = User.new(user_params)
      if @user.save
        redirect_to users_path
      else
        render 'new'
      end
    else
      redirect_to weeks_path, alert: "Not allowed"
    end
  end

  def show
    if current_user.is_admin
      @user = User.find(params[:id])
    else
      redirect_to weeks_path, alert: "Not allowed"
    end
  end

  def profile
    @user = current_user
  end

  def profile_update
    if params[:password].present? && params[:password_confirmation].present? && params[:current_password].present?
      if current_user.valid_password?(params[:current_password])
        if params[:password] == params[:password_confirmation]
          if current_user.update_attributes(password: params[:password])
            bypass_sign_in current_user
            redirect_to profile_path, notice: "Password was updated"
          else
            redirect_to profile_path, alert: "Problem updating passwords"
          end
        else
          redirect_to profile_path, alert: "New passwords dont match"
        end
      else
        redirect_to profile_path, alert: "Current password is incorrect"
      end
    else
      redirect_to profile_path, alert: "You have to fill all required fields"
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :email,
      :password,
      :password_confirmation,
      :is_admin
    )
  end
end
