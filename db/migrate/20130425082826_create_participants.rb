class CreateParticipants < ActiveRecord::Migration
  def self.up
    create_table :participants do |t|
      t.string :username
      t.string :mobile_number
      t.string :token

      t.timestamps
    end
  end

  def self.down
    drop_table :participants
  end
end
