require 'net/http'
require 'uri'

module Candl
  class EventLoaderModel
    Event ||= Struct.new(:dtstart, :dtend, :summary, :description, :location, :uid)
    
    # load events prepared for agenda view
    def self.get_agenda_events(calendar_adress, from, to)
      events = parse_calendar(calendar_adress, from, to)
      spreaded_events = spread_multiday_events(events, from, to)

      sorted_events = (events + spreaded_events.to_a).sort_by do |el|
        [el.dtstart, el.summary]
      end
    end

    # load events for month view
    def self.get_month_events(calendar_adress, from, to)
      events = parse_calendar(calendar_adress, from, to)

      sorted_events = (events).sort_by do |el|
        [el.dtstart, el.summary]
      end
    end

    private

    # build request path to calendar host (google calendar)
    def self.build_google_request_path(calendar_adress, from, to)
      google_test_path = "#{calendar_adress[:path]}#{calendar_adress[:id]}/events?key=#{calendar_adress[:key]}&singleEvents=true&orderBy=startTime&timeMin=#{CGI.escape(from.to_s)}&timeMax=#{CGI.escape(to.to_s)}"
    end

    # parses json response form calendar host (google calendar)
    def self.parse_calendar(calendar_adress, from, to)
      google_test_path = build_google_request_path(calendar_adress, from.to_datetime, to.to_datetime)

      requested_events = JSON.parse(Net::HTTP.get(URI.parse(google_test_path)))

      if requested_events["items"] != nil
        restructured_events = requested_events["items"].map{ |e|
          isDate = e["start"]["date"] != nil
          parsedStart = isDate ? Date.parse(e["start"]["date"]) : DateTime.parse(e["start"]["dateTime"])
          parsedEnd = isDate ? Date.parse(e["end"]["date"]) : DateTime.parse(e["end"]["dateTime"])
          Event.new(parsedStart, parsedEnd, e["summary"], e["description"], e["location"], e["id"]) }
      else
        raise "Calendar event request failed and responded with:\n  #{requested_events}"
      end

      restructured_events.to_a
    end

    # inserts new event starts for events that are multiple day's long so in the agenda one can see them filling multiple day's
    def self.spread_multiday_events(events, from, to)
      unspreaded_events = events.select{ |event| (event.dtend - event.dtstart).to_i > 0 }

      spreaded_events = unspreaded_events.map do |event|
        ([from, (event.dtstart + 1.day)].max .. [(event.dtend - 1.day), to].min).to_a.map do |date|
          Event.new.tap do |e|
            e.dtstart = date.to_date
            e.dtend = event.dtend.to_date
            e.summary = event.summary
            e.location = event.location
            e.description = event.description
            e.uid = event.uid
          end
        end
      end.flatten!
    end
  end
end
