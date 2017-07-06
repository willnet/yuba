class ArtistsController < ApplicationController
  def index
  end

  def new
    @model = Artist::NewService.call
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
