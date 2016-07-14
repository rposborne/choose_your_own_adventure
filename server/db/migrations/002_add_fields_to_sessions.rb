class AddFieldsToSessions < ActiveRecord::Migration
  def up
    down

    create_table :sessions do |t|
      t.string :token
      t.datetime :login_time
      t.integer :current_step
      t.timestamps null: true
    end
  end

  def down
    drop_table :sessions if table_exists?(:sessions)
  end
end
