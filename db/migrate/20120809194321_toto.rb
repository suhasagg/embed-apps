class Toto < ActiveRecord::Migration
  def up
    add_column :apps, :image_url , :string, :default =>"http://payload76.cargocollective.com/1/2/88505/3839876/02_nowicki_poland_1949.jpg"
  end

  def down
  end
end
