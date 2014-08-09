class AddIframe < ActiveRecord::Migration

  def up
    add_column :apps, :iframe_width, :string, :default=>"100%"
    add_column :apps, :iframe_height, :string,:default=>"100%"
  end


  def down
  end
end
