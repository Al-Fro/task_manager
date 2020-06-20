class Web::PasswordResetsController < Web::ApplicationController
  def new
    @password_reset = PasswordResetForm.new
  end

  def edit
    if !(@user = User.find_by(password_reset_token: params[:id]))
      render(:error_page)
    end
  end

  def create
    @password_reset = PasswordResetForm.new(password_reset_params)
    user = @password_reset.user

    if user.present?
      user.generate_password_token!
      UserMailer.reset_password(user).deliver_now
    end

    redirect_to(:new_session)
  end

  def update
    if !(@user = User.find_by(password_reset_token: params[:id]))
      render(:error_page)
    end

    if @user.password_token_invalid?
      redirect_to(:new_password_reset)
    elsif @user.update(user_params)
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
