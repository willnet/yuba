class ArtistForm < Yuba::Form
  model :artist

  property :name
  validates :name, presence: true
end
