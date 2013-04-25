class CreateSms < ActiveRecord::Migration
  def self.up
    create_table :sms do |t|
      t.string :body
      t.string :to
      t.timestamps
    end
  end

  def self.down
    drop_table :sms
  end
end
