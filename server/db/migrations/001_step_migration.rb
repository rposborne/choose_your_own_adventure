class StepMigration < ActiveRecord::Migration
  def up
    drop_table :steps if table_exists?(:steps)
    create_table :steps do |t|
      t.integer "story_id"
      t.text "body"
      t.boolean "termination"
      t.text "option_b"
      t.integer "option_b_id"
      t.text "option_a"
      t.integer "option_a_id"
      t.timestamps null: true
    end

    create_table :stories do |t|
      t.string "title"
      t.timestamps null: true
    end
    
    create_table :sessions do |t|
      t.string 'token'
      t.timestamps null: true
    end
  end

  def down
    drop_table :steps if table_exists?(:steps)
  end
end
