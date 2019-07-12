# frozen_string_literal: true

class TinyMceAssetsController < ApplicationController
  def create
    image = params.fetch(:file) { render_404 }
    tiny_img = TinyMceAsset.new(team_id: current_team.id, saved: false)

    tiny_img.transaction do
      tiny_img.save!
      tiny_img.image.attach(io: image, filename: image.original_filename)
    end

    if tiny_img.persisted?
      render json: {
        image: {
          url: url_for(tiny_img.image),
          token: Base62.encode(tiny_img.id)
        }
      }, content_type: 'text/html'
    else
      render json: {
        error: tiny_img.errors.full_messages
      }, status: :unprocessable_entity
    end
  end
end
