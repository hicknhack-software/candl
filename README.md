# Candl

[![Build Status](https://travis-ci.org/hicknhack-software/candl.svg?branch=master)](https://travis-ci.org/hicknhack-software/candl)
[![Maintainability](https://api.codeclimate.com/v1/badges/b20964b8dd8704d83446/maintainability)](https://codeclimate.com/github/hicknhack-software/candl/maintainability)
[![Gem Version](https://badge.fury.io/rb/candl.svg)](https://badge.fury.io/rb/candl)

This gem helps load and display a calendar from google calendar in an agenda or month style view.

## Usage

The gem consists of mainly three models. One - the event loader model - is focusing on loading the events from the google server via a restfull api and an api key. The other two are the agenda and month model wich offer functionality to organize the data for an agenda or month view. Next to the models are the views wich come with a "_frame.slim" view. This view can be included in a host view as a partial. This way one can display a calendar inside of another page. The "_frame.slim" is the entry point that prepares the model and view for the respective view type (month/agenda). (It does not come with a seperate week view.)

Find an example inclusion of the _frame.slim partial in the show.slim file in candl/spec/dummy/app/views/sample/show.slim.

The main steps to use this gem are:
- Initialize an agenda or month model object with a config that specifies these values:

```json
config = {
  "calendar": {
    "google_calendar_api_host_base_path": "https://www.googleapis.com/calendar/v3/calendars/",
    "calendar_id": "schau-hnh%40web.de",
    "api_key": "AIzaSyB5F1X5hBi8vPsmt1itZTpMluUAjytf6hI"
  },
  "agenda": {
    "display_day_count": "14",
    "days_shift_coefficient": "7"
  },
  "month": {
    "summary_teaser_length_in_characters": "42",
    "delta_start_of_weekday_from_sunday": "1"
  },
  "general": {
    "maps_query_host": "https://www.google.de/maps",
    "maps_query_parameter": "q"
  }
}
```

- The node "calendar" holds all relevant information to the chosen calendar that you want to load events from.
- Under "general" there is the "maps_query_host" wich is the base url to a map service (like google maps in this example) and the "maps_query_parameter". (Maybe in the future there will be more map services, that let one search for a location just via the url and a parameter. But for now i only found gmaps to be able to do this. Like: https://www.google.de/maps/?q=Dresden+Hauptbahnhof)
- In "agenda" you can set the span "display_day_count" of day's considered/loaded in one view and by how many day's it will be shifted "days_shift_coefficient".
- In "month" you can set the "summary_teaser_length_in_characters" and in your view you can truncate the title to that length to reduce the size of the seperate events not to become to big in the view. The "delta_start_of_weekday_from_sunday" can be set to whatever value you need to have the week start at another day than sunday. (Like 1 -> Monday)

Then once configured you can load the events inside of the current timeframe and then use the other functionality to display them nicely.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'candl'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install candl
```

Additionally:
Require the library in the ./config/application.rb of your ruby on rails application.
```ruby
# ./config/application.rb
require 'candl'
```

In the view you want the calendar to appear initialize a configuration hash like so:
```slim
ruby:
  config = {
    calendar: {
      google_calendar_api_host_base_path: "https://www.googleapis.com/calendar/v3/calendars/",
      calendar_id: "schau-hnh%40web.de",
      api_key: "AIzaSyB5F1X5hBi8vPsmt1itZTpMluUAjytf6hI"
    },
    agenda: {
      display_day_count: 14,
      days_shift_coefficient: 7
    },
    month: {
      summary_teaser_length_in_characters: 42,
      delta_start_of_weekday_from_sunday: 1
    },
    general: {
      maps_query_host: "https://www.google.de/maps",
      maps_query_parameter: "q",
      cache_update_interval_in_s: 7200
    }
  }
```
In this example done in a view that uses .slim instead of .erb but in the end config is just a ruby hash that needs to have the right key's and sensible values for them.

Then at the position in your view where the calendar is supposed to show itself:
```slim
= render partial: "candl/calendar/frame", locals: { config: config }
```

## Contributing

Bug reports and pull requests are welcome on GitHub at this repository.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
