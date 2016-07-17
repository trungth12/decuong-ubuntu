class CreateMon < ActiveRecord::Migration
  def change
    create_table :mons do |t|
      t.string :ma_mon_hoc
      t.string :file
    end
  end
end
