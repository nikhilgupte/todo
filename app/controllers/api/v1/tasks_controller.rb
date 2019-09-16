# frozen_string_literal: true

module Api
  module V1
    class TasksController < ApplicationController
      def index
        render json: Task.all
      end

      def update
        task = Task.find(params[:id])
        if task.update(update_params)
          render json: task, status: :ok
        else
          render json: task, status: :unprocessable_entity, serializer: ActiveModel::Serializer::ErrorSerializer
        end
      end

      def create
        task = Task.new(create_params)
        if task.save
          render json: task, status: :created
        else
          render json: task, status: :unprocessable_entity, serializer: ActiveModel::Serializer::ErrorSerializer
        end
      end

      def destroy
        Task.destroy(params[:id])
        head :ok
      end

      private

      def create_params
        ActiveModelSerializers::Deserialization.jsonapi_parse!(params, only: [:title])
      end

      def update_params
        ActiveModelSerializers::Deserialization.jsonapi_parse!(params, only: %i[title tags], keys: { tags: :tag_names })
      end
    end
  end
end
