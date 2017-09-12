class AssociateRuns < ActiveRecord::Migration[5.1]
  def up
    add_column :examples, :duration, :numeric, null: false, default: 0
    remove_column :runs, :total_time

    Run.all.find_each do |r|
      r.update_attributes id: r.rspec_run
    end

    count = Example.all.size
    Example.all.find_each do |e|
      e.update_column :duration, e.properties['duration'].to_f

      count -= 1
      puts count
    end
  end

  def down
    remove_column :examples, :duration
    add_column :runs, :total_time, :integer
  end
end
