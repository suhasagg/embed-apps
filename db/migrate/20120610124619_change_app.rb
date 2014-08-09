class ChangeApp < ActiveRecord::Migration
  def up
    add_column :apps , :redundancy, :integer ,:default=>3
    remove_column :apps , :ui_template

    App.all.each { |app|
    app.redundancy=3
    app.save}

  end


  def down
  end
end
