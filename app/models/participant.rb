class Participant < ActiveRecord::Base

  validates_presence_of :username, :mobile_number
  validates_uniqueness_of :username, :message => "A participant already exists with the given name"
  validates_uniqueness_of :mobile_number, :message => "Mobile number already registered"
  validates_format_of :username, {
    :with => /^[A-Za-z][0-9A-Za-z_]*$/,
    :message => "must start with a character and can only contain characters or digits",
    :allow_blank => false
  }

  uniquify :token, :length => 4, :chars => 0..9

  has_many :votes
end
