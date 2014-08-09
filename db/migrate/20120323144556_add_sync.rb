class AddSync < ActiveRecord::Migration

  def change
    add_column :answers , :ft_sync, :boolean ,:default=>false
    add_column :tasks, :gold_answer, :boolean, :default=>nil
  end

end
