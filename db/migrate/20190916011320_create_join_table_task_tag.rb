class CreateJoinTableTaskTag < ActiveRecord::Migration[5.2]
  def change
    create_join_table :tasks, :tags do |t|
      t.index [:task_id, :tag_id], unique: true
      t.index :tag_id
    end
  end
end
