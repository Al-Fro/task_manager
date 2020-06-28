class UserMailer < ApplicationMailer
  def task_created
    @user = params[:user]
    @task = params[:task]

    mail(to: @user.email, subject: 'New Task Created')
  end

  def task_updated
    @user = params[:user]
    @task = params[:task]

    mail(to: @user.email, subject: 'Task Updated')
  end

  def task_destroyed
    @user = params[:user]
    @task = params[:task]

    mail(to: @user.email, subject: 'Task Destroyed')
  end

  def reset_password(user)
    @user = user

    mail(to: user.email, subject: 'Reset Password')
  end
end
