class Artist::NewService < Crepe::Service
  def call
    form = build_form(artist: Artist.new, albums: Array.new(3) { Album.new })
    Artist::NewViewModel.new(form: form)
  end
end
