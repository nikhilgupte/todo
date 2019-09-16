class Tag < ApplicationRecord
  validates :title, uniqueness: true, length: { maximum: 50 }, presence: true
end
