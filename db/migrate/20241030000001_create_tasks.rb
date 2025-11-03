class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :tasks, :name
  end
end
