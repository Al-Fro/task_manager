class User < ApplicationRecord
  has_many :my_tasks, class_name: 'Task', foreign_key: :author_id
  has_many :assigned_tasks, class_name: 'Task', foreign_key: :assignee_id

  has_secure_password

  validates :first_name, presence: true, length: { minimum: 2 }
  validates :last_name, presence: true, length: { minimum: 2 }
  validates :email, presence: true, format: { with: /@/ }, uniqueness: true
  validates :password, presence: true
  validates :password_confirmation, presence: true

  def generate_password_token!
    self.password_reset_token = generate_token
    self.password_reset_sent_at = Time.current
    save!
  end

  def password_token_invalid?
    day_constant = 24.hours
    (password_reset_sent_at + day_constant) < Time.current
  end

  def generate_token
    SecureRandom.urlsafe_base64
  end
end
