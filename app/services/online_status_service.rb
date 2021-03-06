# Online status service is responsible for dealing with online statuses of the
# users. It checks if they are online at the moment, queries if they were
# online recently.
class OnlineStatusService
  attr_reader :redis, :pusher

  # Initialize a status service.
  #
  # @param redis [Redis] redis connection
  # @param pusher [Pusher] pusher connection
  def initialize(redis: $redis, pusher: Pusher)
    @redis = redis
    @pusher = pusher
  end

  # Check if a channel is occupied.
  #
  # @param channel [String] channel name
  def occupied?(channel)
    # user is online if they have a pusher connection to their private channel
    pusher[channel].info[:occupied]
  end

  # Check if the user is online.
  #
  # @param user [User, Array<String>]
  def online?(user)
    # user is online if they have a pusher connection to their private channel
    id = id_string(user)
    channel = "private-#{id}"
    occupied?(channel)
  end

  # Check the status of the user.
  #
  # @param user [User, Array<String>] user object or user identity string
  # @return [:online, :offline]
  def status(user)
    online?(user) ? :online : :offline
  end

  # Record current timestamp as the last time seen online for user.
  #
  # @param user [User, Array<String>]
  def mark(user)
    redis.set last_seen_key_for(user), Time.now.to_i if online?(user)
  end

  # Get the timestamp of the user's last appearance.
  #
  # @param user [User]
  # @return [Time, nil]
  def last_seen(user)
    last = redis.get(last_seen_key_for(user))
    Time.at(last.to_i) if last
  end

  # Check if the user was online within some window.
  #
  # @param user [User, Array<String>]
  # @param window [Integer] number of seconds
  def was_recently_online?(user, window:)
    last = last_seen(user)
    (last + window) >= Time.now if last
  end

  # Get a redis key to store last seen timestamp.
  def last_seen_key_for(user)
    id = id_string user
    "last_seen:#{id}"
  end

  # @param user [User, Array<String>]
  #
  # @example
  #   id_string [:patient, 123] => 'patient-123'
  #   id_string user1 => 'doctor-456'
  def id_string(user)
    if User === user
      user.id_string
    else
      user.join('-')
    end
  end
end
