# frozen_string_literal: true

class Task < ApplicationRecord
  validates :title, uniqueness: true, length: { maximum: 255 }, presence: true
  has_and_belongs_to_many :tags

  def tag_names=(tag_names)
    tags.clear
    tag_names.each do |tag_name|
      tags << Tag.find_or_create_by(title: tag_name)
    end
  end
end
