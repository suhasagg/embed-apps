class Addtoto < ActiveRecord::Migration
  def up
    rename_column :tasks, :input, :input_task_id
  end

  def down
  end
end
