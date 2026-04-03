class User < ApplicationRecord
  has_secure_password
  has_many :medical_reports

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
  validates :role, inclusion: { in: %w[user doctor admin] }

  before_validation :set_default_role

  private

  def set_default_role
    self.role ||= "user"
  end
end
