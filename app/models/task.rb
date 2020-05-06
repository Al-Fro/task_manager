class Task < ApplicationRecord
  belongs_to :author, class_name: 'User'
  belongs_to :assignee, class_name: 'User', optional: true

  validates :name, presence: true
  validates :description, presence: true
  validates :author, presence: true
  validates :description, length: { maximum: 500 }

  state_machines initial: :new_task do
    state :new_task
    state :in_development
    state :archived
    state :in_qa
    state :in_code_review
    state :ready_for_release
    state :released

    event :state_development do
      transition :new_task => :in_development
      transition :in_qa => :in_development
      transition :in_code_review => :in_development
    end

    event :state_qa do
      transition :in_development => :in_qa
    end

    event :state_code_review do
      transition :in_qa => :in_code_review
    end

    event :state_ready_for_release do
      transition :in_code_review => :in_ready_for_release
    end

    event :state_released do
      transition :in_ready_for_release => :released
    end

    event :state_archived do
      transition :released => :archived
      transition :new_task => :archived
    end
  end
end
