# frozen_string_literal: true

class Tag < ApplicationRecord
  validates :title, uniqueness: true, length: { maximum: 50 }, presence: true

  has_and_belongs_to_many :tasks
end
