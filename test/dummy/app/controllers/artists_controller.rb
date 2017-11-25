class ArtistsController < ApplicationController
  def index
  end

  def new
    service = Artist::CreateService.new(artist: Artist.new)
    render view_model: service.view_model
  end

  def create
    service = Artist::CreateService.call(artist: artist, params: params)

    if service.success?
      redirect_to artists_path
    else
      render :new, view_model: service.view_model
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
