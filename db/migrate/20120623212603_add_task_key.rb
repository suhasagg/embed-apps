class AddTaskKey < ActiveRecord::Migration
  def up
    add_column :apps, :task_column, :string, :default => "task_id"
    App.all.each { |app|
      if  app.task_column.blank?
        app.task_column="task_id"
      end
    }
  end

  def down
  end
end
