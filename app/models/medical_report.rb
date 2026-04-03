class MedicalReport < ApplicationRecord
  belongs_to :user
  has_one_attached :report_file

  validates :report_file, presence: true
end