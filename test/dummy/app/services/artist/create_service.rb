class Artist::CreateService < Yuba::Service
  property :artist
  property :params, optional: true

  def call
    if form.validate(params)
      form.save
    else
      fail!
    end
  end

  def view_model
    @view_model ||= ArtistViewModel.new(form: form)
  end

  private

  def form
    @form ||= ArtistForm.new(model: artist)
  end
end
