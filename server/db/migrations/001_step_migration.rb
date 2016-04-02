class StepMigration < ActiveRecord::Migration
  def up
    down
    create_table :steps do |t|
      t.integer "story_id"
      t.text "body"
      t.boolean "termination"
      t.text "option_b_text"
      t.integer "option_b_step_id"
      t.text "option_a_text"
      t.integer "option_a_step_id"
      t.timestamps null: true
    end

    create_table :stories do |t|
      t.string "title"
      t.integer "first_step_id"
      t.timestamps null: true
    end

    create_table :sessions do |t|
      t.string "token"
      t.timestamps null: true
    end
  end

  def down
    drop_table :steps if table_exists?(:steps)
    drop_table :sessions if table_exists?(:sessions)
    drop_table :stories if table_exists?(:stories)
  end
end
