require 'sequel'

class Message < Sequel::Model
  many_to_one :chat

  def before_create
    self.created_at ||= Time.now
    super
  end
end
