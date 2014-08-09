class ChangeAppColumnnames < ActiveRecord::Migration

  def up

	  rename_column :apps, :input_ft,  :challenges_table_url
	  rename_column :apps, :output_ft, :answers_table_url
	  rename_column :apps, :gist_id, :gist_url
	end

  def down

  end

end
