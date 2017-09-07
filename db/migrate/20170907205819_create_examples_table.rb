class CreateExamplesTable < ActiveRecord::Migration[5.1]
  def change
    create_table :examples do |t|
      t.string :rspec_run, null: false
      t.text :properties
    end

    add_index :examples, :rspec_run
  end
end
