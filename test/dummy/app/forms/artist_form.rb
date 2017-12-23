class ArtistForm < Yuba::Form
  attribute :name
  validates :name, presence: true
end
