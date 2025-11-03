class CreateTaskCompletions < ActiveRecord::Migration[7.0]
  def change
    create_table :task_completions do |t|
      t.references :task, null: false, foreign_key: true
      t.datetime :completed_at, null: false

      t.timestamps
    end

    add_index :task_completions, :completed_at
    add_index :task_completions, [:task_id, :completed_at]
  end
end
