require 'rspectacles/app/models/example'
require 'rspectacles/app/models/run'

class CreateRuns < ActiveRecord::Migration[5.1]
  def change
    create_table :runs do |t|
      t.integer :total_time
      t.string :rspec_run, null: false

      t.timestamps
    end

    add_index :runs, :rspec_run, unique: true
    add_reference :examples, :run

    Example.all.distinct.pluck(:rspec_run).each do |run|
      Run.where(rspec_run: run).first_or_create
    end
  end
end
