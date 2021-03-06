class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :async

  belongs_to :identity, polymorphic: true, autosave: true, validate: true
  accepts_nested_attributes_for :identity

  def me
    identity.me
  end

  def role
    identity.class.name.downcase
  end

  def doctor?
    role == 'doctor'
  end

  def patient?
    role == 'patient'
  end

  def full_name
    identity.full_name
  end

  def id_string
    self.class.id_string role, identity.id
  end

  def pusher_channel_name
    self.class.pusher_channel_name role, identity_id
  end

  def pulser_channel_name
    "private-#{role}-online-pulser"
  end

  def self.id_string(role, identity_id)
    "#{role}-#{identity_id}"
  end

  def self.pusher_channel_name(role, identity_id)
    "private-#{id_string(role, identity_id)}"
  end
end
