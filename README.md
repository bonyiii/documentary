[![Build Status](https://travis-ci.org/bonyiii/documentary.svg?branch=master)](https://travis-ci.org/bonyiii/documentary)

# Documentary

Documentary provides "living" API documentation for your application.
The concept is to write code which is a living documentation at the same time.
The documentation should be placed right under the controller action, so that it is immeadiately clear what params it expects.
The exact same code should provide permitted params definition for strong params and documentation for
API clients, being it human or machine.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'documentary'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install documentary

## Usage

Include ```Documentary::Params``` in your controller:

``` ruby
class ApplicationController < ActionController::Base
  include Documentary::Params
  protect_from_forgery
end
```

Define params for each action in your controller:

``` ruby
class CarsController < ApplicationController
  def create
  end
  params :create do
    required :name, type: String, desc: "Name of car"
    required "vintage(1i)", type: String, desc: "Year"
    required "vintage(2i)", type: String, desc: "Month"
    optional "vintage(3i)", type: String, desc: "Day"
  end
end
```

### Param definitions

Right now documentary simply indicates whether a param is required or optional but does not do any kind of validation on the incoming params.
That should be handled by Rails default validation techniques.

A param can be:
  - optional
  - required

### Param options

Param options consists following elements:

  - Param Name: Name of the argument (compulsory)
    - Can be a symbol or string
  - Keyword arguments (all are optional):
	  - type: Can be anything that respond to ```to_s```
	  - desc: Describe what the given parameter does
	  - authorized: Response will include the given param if evaluated true
		  - Expects a symbol or a proc, any kind of authorization logic can be implemented.
		  - For proc will receive controller instance as input parameter.
		  - For symbol it will call an instance method with that name on the controller

### Querying the documentation

When a request header include ```Describe-Params``` then the params documentation will be returned
for given controller action and the action will not run.

By default every controller which includes ```Documentar::Params``` will mix in ```describe_params```
method which can respond with json and xml format.

```ruby
def describe_params
  respond_to do |format|
    format.json { render json: params_of(action_name) }
    format.xml { render xml: params_of(action_name) }
  end
end
```

```describe_params``` can be overriden per controller basis to support other formats, for example: YAML.

## Features

- [X] Strong Paramters
- [X] Authorization
- [ ] Generate test ?
- [ ] Raise error if required param is missing
- [ ] Swagger compatible output

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Documentary project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/documentary/blob/master/CODE_OF_CONDUCT.md).
