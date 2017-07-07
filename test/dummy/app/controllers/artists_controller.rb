class ArtistsController < ApplicationController
  def index
  end

  def new
    @model = Artist::NewService.call
  end

  def create
    @model = Artist::CreateService.call(params)

    if @model.success?
      redirect_to artists_path
    else
      render :new
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
