class Task < ApplicationRecord
  belongs_to :author, class_name: 'User'
  belongs_to :assignee, class_name: 'User', optional: true

  has_one_attached :image

  validates :name, presence: true
  validates :description, presence: true
  validates :author, presence: true
  validates :description, length: { maximum: 500 }

  state_machine initial: :new_task do
    state :new_task
    state :in_development
    state :archived
    state :in_qa
    state :in_code_review
    state :ready_for_release
    state :released

    event :start_development do
      transition new_task: :in_development
      transition in_qa: :in_development
      transition in_code_review: :in_development
    end

    event :start_qa do
      transition in_development: :in_qa
    end

    event :to_review do
      transition in_qa: :in_code_review
    end

    event :push_to_release do
      transition in_code_review: :in_ready_for_release
    end

    event :release do
      transition in_ready_for_release: :released
    end

    event :archive do
      transition released: :archived
      transition new_task: :archived
    end
  end
end
