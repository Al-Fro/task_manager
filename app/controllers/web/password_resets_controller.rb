class Web::PasswordResetsController < Web::ApplicationController
  def new
    @password_reset = PasswordResetForm.new
  end

  def create
    @password_reset = PasswordResetForm.new(password_reset_params)

    user.send_password_reset if user
    flash[:notice] = 'E-mail sent with password reset instructions.'
    redirect_to(:new_session)
  end
  
  def password_reset_params
    params.require(:password_reset_form).permit(:email)
  end
end
