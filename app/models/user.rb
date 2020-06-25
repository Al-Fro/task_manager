class User < ApplicationRecord
  DAY_CONST = 24.hours

  has_many :my_tasks, class_name: 'Task', foreign_key: :author_id
  has_many :assigned_tasks, class_name: 'Task', foreign_key: :assignee_id

  has_secure_password

  validates :first_name, presence: true, length: { minimum: 2 }
  validates :last_name, presence: true, length: { minimum: 2 }
  validates :email, presence: true, format: { with: /@/ }, uniqueness: true

  def generate_password_token!
    self.password_reset_token = generate_token
    self.password_reset_sent_at = Time.current
    save!
  end

  def password_token_outtimed?
    (password_reset_sent_at + DAY_CONST) < Time.current
  end

  def generate_token
    token = SecureRandom.urlsafe_base64

    User.find_by(password_reset_token: token) ? generate_token : token
  end
end
