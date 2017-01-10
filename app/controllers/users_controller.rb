class UsersController < ApplicationController
  skip_before_action :require_login, only: [:new, :create], raise: false

  def show
    @user = User.find_by!(username: params[:username])
  end

  def new
    @user = User.new
  end

  def create
    @user = sign_up(user_params)

    if @user.valid?
      sign_in(@user)
      redirect_to explore_path, notice: t(".success", name: @user.username)
    else
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :username)
  end
end
