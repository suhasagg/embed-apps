class ChangeApp2 < ActiveRecord::Migration
  def up
    change_column :apps , :description, :text
  end

  def down
  end
end
