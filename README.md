# Candl

[![Build Status](https://travis-ci.org/hicknhack-software/candl.svg?branch=master)](https://travis-ci.org/hicknhack-software/candl)
[![Maintainability](https://api.codeclimate.com/v1/badges/b20964b8dd8704d83446/maintainability)](https://codeclimate.com/github/hicknhack-software/candl/maintainability)
[![Gem Version](https://badge.fury.io/rb/candl.svg)](https://badge.fury.io/rb/candl)

This gem helps load and display a calendar from google calendar in an agenda or month style view.

## Overview

The gem consists of mainly three models and views. One - the event loader model - is focusing on loading the events from the google server via a restfull api and an api key. The other two are the agenda and month model wich offer functionality to organize the data for an agenda or month view. Next to the models are the views wich come with a ```_frame.slim``` view. This view can be included in a host view as a partial. This way one can display a calendar inside of another page. The ```_frame.slim``` is the entry point that prepares the model and view for the respective view type (month/agenda). (It does not come with a seperate week view.)

## Pre-Installation

This gem depends on a few other gems that are quite common so your application may already depend on them. To make dependency matters easier this gem will not depend on them on its own but rather expects these dependencies to be present in your application. This way there should be less dependency version collisions since you get to define them. (This gem does depend on them but it only uses base level functionality so that it shouldn't matter much what version you use.)

These dependencies are:
- material_icons
- jquery3 (jquery_rails)
- turbolinks
- bootstrap (bootstrap-sass)

So make sure to also have these gems in your gemfile and installed them via ```bundle install```.

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
Require the library in the ```./app/assets/stylesheets/application.scss``` (or .css) of your ruby on rails application like so:
```scss
# ./app/assets/stylesheets/application.scss
/*
 ...
 *= require material_icons
 *= require candl
 ...
 */
```

And also require the library in the ```./app/assets/javascripts/application.js``` of your ruby on rails application like so:
```javascript
# ./app/assets/javascripts/application.js
//  ...
//= require jquery3
//= require turbolinks
//= require bootstrap
//= require candl
//  ...
```

You may look in ```./spec/dummy/app/assets/``` and there in ```./javascripts``` and ```./stylesheets``` to see how it is done there. An example inclusion of the ```_frame.slim``` partial in a view can be found in ```./spec/dummy/app/views/sample/show.slim```. Or to see the calendar in action run ```rails server``` in your command line interface (while beeing in the gems root folder) and when the server is started navigate to ```localhost:3000/calendar``` and load the page.

This example uses .slim instead of .erb if you need help with the syntax try some of the online .slim to .erb syntax converters.

The partial needs to set a local config variable that is a hash containing the needed configuration. Create the hash in the view you want to render the partial in like this:

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

Tipps:

- The node "calendar" holds all relevant information to the chosen calendar that you want to load events from.
- Under "general" there is the "maps_query_host" wich is the base url to a map service (like google maps in this example) and the "maps_query_parameter". (Maybe in the future there will be more map services, that let one search for a location just via the url and a parameter. But for now i only found gmaps to be able to do this. Like: https://www.google.de/maps/?q=Dresden+Hauptbahnhof)
- In "agenda" you can set the span "display_day_count" of day's considered/loaded in one view and by how many day's it will be shifted "days_shift_coefficient".
- In "month" you can set the "summary_teaser_length_in_characters" and in your view you can truncate the title to that length to reduce the size of the seperate events not to become to big in the view. The "delta_start_of_weekday_from_sunday" can be set to whatever value you need to have the week start at another day than sunday. (Like 1 -> Monday)

For most values there are sensible standards defined but for the sake of clarity you may still define them in the config.

Then at the position in your view where the calendar is supposed to show itself:
```slim
= render partial: "candl/calendar/frame", locals: { config: config }
```

## Contributing

Bug reports and pull requests are welcome on GitHub at this repository.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
