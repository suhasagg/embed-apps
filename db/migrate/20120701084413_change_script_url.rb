class ChangeScriptUrl < ActiveRecord::Migration
  def up
  	rename_column :apps , :script_url, :gist_id
  end

  def down
  end
end
