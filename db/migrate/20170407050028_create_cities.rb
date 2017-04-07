class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string :name
      t.string :state
      t.string :country
      t.decimal :latitude
      t.decimal :longitude

      t.timestamps null: false
    end
  end
end
