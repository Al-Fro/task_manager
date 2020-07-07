class Web::PasswordResetsController < Web::ApplicationController
  def new
    @password_reset = PasswordResetForm.new
  end
  
  def create
    @password_reset = PasswordResetForm.new(password_reset_params)
    user = @password_reset.user

    if user.present? && @password_reset.valid?
      user.generate_password_token!
      UserMailer.reset_password(user).deliver_now
    end

    redirect_to(:new_session)
  end
  
  def wrong_token
  end  

  def edit
    @user = User.find_by(password_reset_token: params[:id])
    if @user.blank? || @user.password_token_outdated?
      render(:wrong_token)
    end
  end

  def update
    @user = User.find_by(password_reset_token: params[:id])

    if @user.update(user_params)
      @user.password_reset_token = nil
      @user.save
      redirect_to(:new_session)
    else
      render(:edit)
    end
  end

  private

  def user_params
    params.require(@user.type.downcase).permit(:password, :password_confirmation)
  end

  def password_reset_params
    params.require(:password_reset_form).permit(:email)
  end
end
