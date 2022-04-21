class UsersController < ApplicationController
  before_action :set_user, only: [:show, :follow, :unfollow]
  before_action :authenticate_user!, only: [:my_token]
  def show
    @decks = @user.decks.visible_to(current_user).active.page(params[:page]).includes([{deck_list: :archetype},:author]).per(6)
    respond_to do |format|
      format.html
    end
  end

  def my_token
    if current_user.access_token.blank?
      current_user.generate_access_token!
    end
    respond_to do |format|
      format.json { render json: {access_token: current_user.access_token} }
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'Deck was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def generate_access_token
    unless current_user
      redirect_to "/", alert: 'You are not signed in.'
    end
    current_user.generate_access_token!
    redirect_to user_path(current_user)

  end

  def follow
    unless current_user
      redirect_to @user, alert: 'You are not signed in.'
    end

    current_user.follow(@user)
    redirect_to @user, notice: "You are now following #{@user}"
  end

  def unfollow
    unless current_user
      redirect_to @user, alert: 'You are not signed in.'
    end

    current_user.stop_following(@user)
    redirect_to @user, notice: "You are no longer following #{@user}"
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:name, :receive_weekly_report)
  end
end
