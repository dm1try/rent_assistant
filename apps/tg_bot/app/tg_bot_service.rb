require 'drb/drb'
require 'telegram/bot'
require 'models/chat'
require 'time_difference'

class TgBotService
  include DRb::DRbUndumped

  CITY_NAMES_TO_PL = {
    'krakow' => 'Kraków',
    'warszawa' => 'Warszawa',
    'wroclaw' => 'Wrocław',
    'gdansk' => 'Gdańsk',
  }.freeze

  def initialize
    @crawler = DRbObject.new_with_uri(ENV['CRAWLER_DRB_URI'])
  end

  def start_bot
    @bot_thread = Thread.new do
      Telegram::Bot::Client.run(ENV['TELEGRAM_TOKEN']) do |bot|
        bot.listen do |message|
          case message
          when Telegram::Bot::Types::Message
            handle_message(bot, message)
          when Telegram::Bot::Types::CallbackQuery
            handle_callback_query(bot, message)
          end
        end
      end
    end
    true
  rescue => e
    $logger&.error "Error: #{e}"
    false
  end

  def stop_bot
    @bot_thread&.kill
    true
  end

  def handle_callback_query(bot, query_result)
    chat_id = query_result.message&.chat&.id || query_result.from.id
    chat = Chat.find_or_create_by_tg_id(chat_id)
    payload = JSON.parse(query_result.data)
    case payload['action']
    when 'city_filter_selected'
      kb = [
        CITY_NAMES_TO_PL.map do |city_name, city_name_pl|
          inline_button_with_action(city_name_pl, 'city_selected', city: city_name)
        end
      ]

      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
      bot.api.send_message(chat_id: chat.tg_id, text: 'Choose city', reply_markup: markup)
    when 'city_selected'
      city = payload['city']
      chat.update_filters(city: city)
      rewatch(chat) if chat.active
      bot.api.send_message(chat_id: chat.tg_id, text: "City selected!\n#{watching_message(chat)}")
    when 'price_filter_selected'
      chat.update_state(current_action: 'set_min_price')
      choose_range_reply(bot, query_result.message, 'Minimum price?', ['2000', '3000', '3500', '4000'])
    when 'area_filter_selected'
      chat.update_state(current_action: 'set_min_area')
      choose_range_reply(bot, query_result.message, 'Minimum area?', ['20', '30', '40', '50'])
    when 'filters_clear'
      chat = Chat.find_or_create_by_tg_id(chat_id)
      # save chosen city
      city = chat.filters[:city]
      chat.clear_filters
      chat.update_filters(city: city)
      rewatch(chat) if chat.active
      bot.api.send_message(chat_id: chat.tg_id, text: "Filters cleared!\n#{watching_message(chat)}")
    end
  end

  def handle_message(bot, message)
    if message.text.nil?
      $logger&.info "Received message with nil text: #{message.inspect}"
      return
    end

    chat = Chat.find_or_create_by_tg_id(message.chat.id)
    case chat.state[:current_action]
    when 'set_min_price'
      chat.update_state(min_price: message.text.to_i, current_action: 'set_max_price')
      choose_range_reply(bot, message, 'Maximum price?', ['4000', '5000', '6000', '7000'])
      return
    when 'set_max_price'
      chat.update_state(max_price: message.text.to_i, current_action: nil)
      chat.update_filters(price: { min: chat.state[:min_price], max: chat.state[:max_price] })
      bot.api.send_message(chat_id: message.chat.id, text: watching_message(chat) , reply_markup: Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true))
      return
    when 'set_min_area'
      chat.update_state(min_area: message.text.to_i, current_action: 'set_max_area')
      choose_range_reply(bot, message, 'Maximum area?', ['50', '60', '80', '100'])
      return
    when 'set_max_area'
      chat.update_state(max_area: message.text.to_i, current_action: nil)
      chat.update_filters(area: { min: chat.state[:min_area], max: chat.state[:max_area] })
      bot.api.send_message(chat_id: message.chat.id, text: watching_message(chat) , reply_markup: Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true))
      rewatch(chat) if chat.active
      return
    end

    if message.text.start_with?('/')
      command_params = message.text[1..].split(' ')
      case command_params[0]
      when 'start', 'help'
        chat = Chat.find_or_create_by_tg_id(message.chat.id)
        chat.update(active: true)

        bot.api.send_message(chat_id: message.chat.id, text: help_message)
      when 'stop'
        chat = Chat.find_or_create_by_tg_id(message.chat.id)
        chat.update(active: false)
        @crawler.unwatch(search_id: message.chat.id)

        bot.api.send_message(chat_id: message.chat.id, text: "You won't receive notifications anymore, #{message.from.first_name}")
      when 'watch'
        chat = Chat.find_or_create_by_tg_id(message.chat.id)
        if chat.filters[:city].nil?
          kb = [
            CITY_NAMES_TO_PL.map do |city_name, city_name_pl|
              inline_button_with_action(city_name_pl, 'city_selected', city: city_name)
            end
          ]

          markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
          bot.api.send_message(chat_id: message.chat.id, text: 'You should choose a city at least', reply_markup: markup)
        else
          chat.update(active: true)
          rewatch(chat)
          bot.api.send_message(chat_id: message.chat.id, text: watching_message(chat) ,
            reply_markup: Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true))

        end
      when 'filter'
        kb = [[
          inline_button_with_action('City', 'city_filter_selected'),
          inline_button_with_action('Price', 'price_filter_selected'),
          inline_button_with_action('Area', 'area_filter_selected'),
          inline_button_with_action('Clear all', 'filters_clear')
        ]]
        markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
        bot.api.send_message(chat_id: message.chat.id, text: 'Choose a filter or clear all of them', reply_markup: markup)
      when 'status'
        chat = Chat.find_or_create_by_tg_id(message.chat.id)
        status_message = "Notifications are #{chat.active ? 'ON' : 'OFF'}\n"
        status_message += watching_message(chat)
        bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: status_message)
      else
        bot.api.send_message(chat_id: message.chat.id, text: "I don't understand you, #{message.from.first_name}. To see available commands, type /help")
      end
    else
      bot.api.send_message(chat_id: message.chat.id, text: "I don't understand you, #{message.from.first_name}. To see available commands, type /help", reply_markup: {hide_keyboard: true})
    end
  end

  def update(notify_type, args)
    listing = args[:listing]
    matched_search_ids = args[:matched_search_ids]

    $logger&.info "New listing found: #{listing[:url]}"

    listing[:images] ||= []

    images = listing[:images].take(3).each_with_index.map do |image, index|
      params = {media: image}

      if index == 0
        params[:caption] = <<~EOS
          #{listing[:address]}, #{listing[:area]} m2, #{listing[:price]} PLN
          #{listing[:url]}
          Created #{humanize_time(listing[:source][:created_at])}
          Updated #{humanize_time(listing[:source][:updated_at])}
        EOS
      end

      Telegram::Bot::Types::InputMediaPhoto.new(params)
    end

    matched_search_ids.each do |search_id|
     # Telegram::Bot::Api.new(ENV['TELEGRAM_TOKEN']).send_message(chat_id: search_id, text: "New listing found: #{listing[:url]}, #{listing[:price]}, #{listing[:address]}")
      Telegram::Bot::Api.new(ENV['TELEGRAM_TOKEN']).send_media_group(chat_id: search_id, media: images)
    end
  rescue => e
    $logger&.error e
  end

  def help_message
    <<~EOS
      Available commands:
      /filter - set filters
      /watch - start watching
      /stop - stop watching
      /status - show watch status and filters
      /help - show help
    EOS
  end

  private

  def watching_message(chat)
    if chat.active
    <<~EOS
      Watching in #{CITY_NAMES_TO_PL[chat.filters[:city]]}, to stop watching type /stop
      #{chat.filters[:price] ? "Price between #{chat.filters[:price][:min]} and #{chat.filters[:price][:max]}" : ''}
      #{chat.filters[:area] ? "Area between #{chat.filters[:area][:min]} and #{chat.filters[:area][:max]}" : ''}
    EOS
    else
    <<~EOS
      #{CITY_NAMES_TO_PL[chat.filters[:city]]} is choosen, to start watching type /watch
      #{chat.filters[:price] ? "Price between #{chat.filters[:price][:min]} and #{chat.filters[:price][:max]}" : ''}
      #{chat.filters[:area] ? "Area between #{chat.filters[:area][:min]} and #{chat.filters[:area][:max]}" : ''}
    EOS
    end
  end

  def rewatch(chat)
    @crawler.unwatch(search_id: chat.tg_id)
    @crawler.watch(search_id: chat.tg_id,city: chat.filters[:city], filters: chat.filters)
  end

  def choose_range_reply(bot, message, question, values)
    answers = Telegram::Bot::Types::ReplyKeyboardMarkup.new(
      keyboard: [
        values.map { |value| { text: value } }
      ],
      one_time_keyboard: true
    )
    bot.api.send_message(chat_id: message.chat.id, text: question, reply_markup: answers)
  end

  def inline_button_with_action(text, action, data = {})
    callback_data = { action: action }.merge(data)
    callback_data = JSON.generate(callback_data)
    Telegram::Bot::Types::InlineKeyboardButton.new(text: text, callback_data: callback_data)
  end

  private

  def humanize_time(time)
    now_diff = Time.now - Time.parse(time)
    if now_diff < (3600 * 24)
      # less than 24 hours ago
      "#{TimeDifference.between(time, Time.now).humanize} ago"
    else
      # more than 24 hours ago
      Time.parse(time).strftime('%d %b %Y %H:%M')
    end
  end
end
