class AddAppState < ActiveRecord::Migration
  def up

    add_column :apps, :status, :integer, :default=>0
  end

  def down
  end
end
