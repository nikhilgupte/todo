# frozen_string_literal: true

class TaskSerializer < ActiveModel::Serializer
  attributes :id, :title

  has_many :tags
end
