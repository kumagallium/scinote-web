# frozen_string_literal: true

module Api
  module V1
    class TaskInventoryItemsController < BaseController
      before_action :load_team
      before_action :load_project
      before_action :load_experiment
      before_action :load_task

      def index
        items =
          @task.repository_rows
               .includes(repository_cells: :repository_column)
               .preload(repository_cells: :value)
               .page(params.dig(:page, :number))
               .per(params.dig(:page, :size))
        render jsonapi: items,
               each_serializer: InventoryItemSerializer,
               show_repository: true,
               include: include_params
      end

      def show
        render jsonapi: @task.repository_rows.find(params.require(:id)),
               serializer: InventoryItemSerializer,
               show_repository: true,
               include: %i(inventory_cells inventory)
      end

      private

      def permitted_includes
        %w(inventory_cells)
      end
    end
  end
end
