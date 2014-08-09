class UnitsToAnswer < ActiveRecord::Migration
  def up
    rename_table :units, :answers
  end

  def down
    rename_table :answers,:units
  end
end
