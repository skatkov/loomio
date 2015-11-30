class MessageChannelService
  class AccessDeniedError < StandardError; end
  class UnknownChannelError < StandardError; end

  def self.subscribe_to(user:, model:)
    raise AccessDeniedError.new   unless user.ability.can?(:subscribe_to, model)
    raise UnknownChannelError.new unless model.respond_to?(:message_channel)
    PrivatePub.subscription(channel: model.message_channel, server: Rails.application.secrets.faye_url)
  end

  def self.publish(data, to:)
    return unless Rails.application.secrets.faye_url.present? && to.message_channel
    if ENV['DELAY_FAYE']
      PrivatePub.delay(priority: 10).publish_to(to.message_channel, data)
    else
      PrivatePub.publish_to(to.message_channel, data)
    end
  end
end
