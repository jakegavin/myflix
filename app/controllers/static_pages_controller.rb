class StaticPagesController < ApplicationController
  def front
    redirect_to home_path if logged_in?
  end

  def invalid_token
    redirect_to home_path if logged_in?
  end

  def password_reset_confirmation
    redirect_to home_path if logged_in?
  end
end