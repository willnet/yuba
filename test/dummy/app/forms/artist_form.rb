class ArtistForm < Crepe::Form
  model :artist

  attribute :artist do
    attribute :name
    validates :name, presence: true
  end

  collection :albums do
    attribute :title
    attribute :published_on, :date

    validates :title, presence: true
    validates :published_on, presence: true
  end
end
