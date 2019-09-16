class Api::V1::TagsController < ApplicationController

  def index
    render json: Tag.all
  end

  def update
    tag = Tag.find(params[:id])
    if tag.update(tag_params)
      render json: tag, status: :ok
    else
      render json: tag, status: :unprocessable_entity, serializer: ActiveModel::Serializer::ErrorSerializer
    end
  end

  def create
    tag = Tag.new(tag_params)
    if tag.save
      render json: tag, status: :created
    else
      render json: tag, status: :unprocessable_entity, serializer: ActiveModel::Serializer::ErrorSerializer
    end
  end

  private

  def tag_params
    ActiveModelSerializers::Deserialization.jsonapi_parse!(params, only: [:title])
  end

end
