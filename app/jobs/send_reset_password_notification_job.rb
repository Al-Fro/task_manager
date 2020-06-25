class SendResetPasswordNotificationJob < ApplicationJob
  sidekiq_options queue: :mailers
  sidekiq_throttle_as :mailer
  sidekiq_options lock: :until_and_while_executing, on_conflict: { client: :log, server: :reject }

  def perform(user_id)
    user = User.find(user_id)

    UserMailer.with(user: user).reset_password(user).deliver_now
  end
end
