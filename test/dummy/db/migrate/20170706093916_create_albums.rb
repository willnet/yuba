class CreateAlbums < ActiveRecord::Migration[5.1]
  def change
    create_table :albums do |t|
      t.references :artist, foreign_key: true
      t.string :title
      t.date :published_on

      t.timestamps
    end
  end
end
