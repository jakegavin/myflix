class AuthenticatedUserController < ApplicationController

  before_action :require_user

end