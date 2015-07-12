class CreateCrawls < ActiveRecord::Migration
  def change
    create_table :crawls do |t|
      t.text :contents
      t.string :name
      t.string :name_verbose
    end
  end
end
