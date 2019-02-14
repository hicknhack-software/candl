module Candl
  class AgendaModel
    # Attributes one needs to access from the "outside"
    attr_reader :initialization_successful

    attr_reader :display_day_count
    attr_reader :days_shift_coefficient

    attr_reader :agenda_grouped_events

    # Minimal json conifg for agenda_model example:
    # config = { \
    #   calendar: { \
    #     google_calendar_api_host_base_path: "https://www.googleapis.com/calendar/v3/calendars/", \
    #     calendar_id: "schau-hnh%40web.de", \
    #     api_key: "AIzaSyB5F1X5hBi8vPsmt1itZTpMluUAjytf6hI" \
    #   }, \
    #   agenda: { \
    #     display_day_count: 14, \
    #     days_shift_coefficient: 7 \
    #   }, \
    #   month: { \
    #     summary_teaser_length_in_characters: 42, \
    #     delta_start_of_weekday_from_sunday: 1 \
    #   }, \
    #   general: { \
    #     maps_query_host: "https://www.google.de/maps", \
    #     maps_query_parameter: "q", \
    #     cache_update_interval_in_s: 7200 \
    #   } \
    # }
    def initialize(config, current_shift_factor, date_today = Date.today)
      self.google_calendar_base_path = config[:calendar][:google_calendar_api_host_base_path] ||= "https://www.googleapis.com/calendar/v3/calendars/"
      self.calendar_id = config[:calendar][:calendar_id]
      self.api_key = config[:calendar][:api_key]

      self.display_day_count = config[:agenda][:display_day_count] ||= 14
      self.days_shift_coefficient = config[:agenda][:days_shift_coefficient] ||= 7

      self.maps_query_host = config[:general][:maps_query_host] ||= "https://www.google.de/maps"
      self.maps_query_parameter = config[:general][:maps_query_parameter] ||= "q"

      from = current_start_date(current_shift_factor, date_today)
      to = current_end_date(current_shift_factor, date_today)

      self.initialization_successful = true
      begin
        events = agenda_events(from, to)
      rescue => exception
        self.initialization_successful = false
        logger.error "ERROR: #{exception}"
      end

      self.agenda_grouped_events = get_days_grouped_events(events)
    end

    # builds base path of current view
    def path(page_path, params = {})
      ActionDispatch::Http::URL.path_for path: page_path, params: {v: 'a'}.merge(params)
    end

    # builds path to previous/upcoming week
    def previous_path(page_path, current_shift_factor)
      week_shift_path(page_path, current_shift_factor, -1)
    end

    def upcoming_path(page_path, current_shift_factor)
      week_shift_path(page_path, current_shift_factor, +1)
    end

    def week_shift_path(page_path, current_shift_factor, shift_factor)
      path(page_path , s: (current_shift_factor.to_i + shift_factor.to_i).to_s)
    end

    # current shift factor for switching between calendar views from agenda to agenda
    def current_shift_for_agenda(current_shift_factor)
      current_shift_factor
    end

    # current shift factor for switching between calendar views from agenda to month
    def current_shift_for_month(current_shift_factor, today_date = Date.today)
      date_span = (current_end_date(current_shift_factor, today_date) - current_start_date(current_shift_factor, today_date)).to_i
      midway_date = (current_start_date(current_shift_factor, today_date) + (date_span / 2))

      current_month_shift = ((midway_date.year * 12 + midway_date.month) - (today_date.year * 12 + today_date.month)).to_i

      current_month_shift
    end

    # date of current start day of agenda
    def current_start_date(current_shift_factor, today_date = Date.today)
      today_date + (current_shift_factor.to_i * days_shift_coefficient).days
    end

    # date of current end day of agenda
    def current_end_date(current_shift_factor, today_date = Date.today)
      today_date + (current_shift_factor.to_i * days_shift_coefficient + display_day_count).days
    end

    # helps apply styling to a special date
    def self.emphasize_date(check_date, emphasized_date, emphasized, regular)
      check_date.to_date == emphasized_date.to_date ? emphasized : regular
    end

    # build a short event summary (for popups etc.)
    def self.summary_title(event)
      event.summary.to_s.force_encoding("UTF-8") + "\n" + event.location.to_s.force_encoding("UTF-8") + "\n" + event.description.to_s.force_encoding("UTF-8")
    end

    # build a google maps path from the  adress details
    def address_to_maps_path(address)
      ActionDispatch::Http::URL.path_for path: maps_query_host, params: Hash[maps_query_parameter.to_s, address.force_encoding("UTF-8").gsub(" ", "+")]
    end

    private

    # load events for agenda view
    def agenda_events(from, to)
      EventLoaderModel.get_agenda_events(google_calendar_base_path, calendar_id, api_key, from, to)
    end

    # load events for agenda view grouped by day
    def get_days_grouped_events(events)
      events.group_by { |event| event.dtstart.to_date }
    end

    attr_writer :initialization_successful

    attr_writer :display_day_count
    attr_writer :days_shift_coefficient

    attr_writer :agenda_grouped_events

    attr_accessor :calendar_id
    attr_accessor :api_key

    attr_accessor :google_calendar_base_path
    attr_accessor :maps_query_host
    attr_accessor :maps_query_parameter

  end
end
