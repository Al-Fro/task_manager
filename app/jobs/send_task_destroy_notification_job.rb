class SendTaskDestroyNotificationJob < ApplicationJob
  sidekiq_options queue: :mailers
  sidekiq_throttle_as :mailer
  sidekiq_options lock: :until_and_while_executing, on_conflict: { client: :log, server: :reject }

  def perform(task_id, user_id)
    user = User.find(user_id)

    UserMailer.with(user: user, task_id: task_id).task_destroyed.deliver_now
  end
end
