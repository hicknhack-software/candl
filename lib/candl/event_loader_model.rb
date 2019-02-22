require 'net/http'
require 'uri'

module Candl
  class EventLoaderModel
    Event ||= Struct.new(:dtstart, :dtend, :summary, :description, :location, :uid)
    
    # load events prepared for agenda view
    def self.get_events(calendar_adress, from, to, view)
      events = parse_calendar(calendar_adress, from, to)

      if view == :month
        sorted_events = (events).sort_by do |el|
          [el.dtstart, el.summary]
        end
      elsif view == :agenda
        spreaded_events = spread_multiday_events(events, from, to)

        sorted_events = (events + spreaded_events.to_a).sort_by do |el|
          [el.dtstart, el.summary]
        end
      else
        raise `Unknown view type: #{view}`
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
        restructured_events = parse_event_time_type(requested_events)
      else
        raise "Calendar event request failed and responded with:\n  #{requested_events}"
      end

      restructured_events.to_a
    end

    def self.parse_event_time_type(events)
      events["items"].map{ |e|
        if e["start"]["date"] != nil
          parsedStart = Date.parse(e["start"]["date"])
          parsedEnd = Date.parse(e["end"]["date"])
        else
          parsedStart = DateTime.parse(e["start"]["dateTime"])
          parsedEnd = DateTime.parse(e["end"]["dateTime"])
        end
        Event.new(parsedStart, parsedEnd, e["summary"], e["description"], e["location"], e["id"]) }
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
