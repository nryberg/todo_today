class AddUserToTasks < ActiveRecord::Migration[7.0]
  def up
    # First, add the user_id column as nullable
    add_column :tasks, :user_id, :bigint

    # Create a default user if there are existing tasks and no users
    if Task.exists? && !User.exists?
      default_user = User.create!(
        email: 'admin@todoapp.local',
        name: 'Default User',
        password: 'password123',
        password_confirmation: 'password123'
      )

      # Assign all existing tasks to the default user
      Task.update_all(user_id: default_user.id)

      puts "Created default user (#{default_user.email}) and assigned #{Task.count} existing tasks"
    elsif Task.exists? && User.exists?
      # If users exist, assign existing tasks to the first user
      first_user = User.first
      Task.where(user_id: nil).update_all(user_id: first_user.id)

      puts "Assigned #{Task.where(user_id: first_user.id).count} tasks to user: #{first_user.email}"
    end

    # Now make the column NOT NULL and add foreign key
    change_column_null :tasks, :user_id, false
    add_foreign_key :tasks, :users

    # Add index for better query performance
    add_index :tasks, [:user_id, :created_at]
  end

  def down
    remove_index :tasks, [:user_id, :created_at]
    remove_foreign_key :tasks, :users
    remove_column :tasks, :user_id
  end
end
