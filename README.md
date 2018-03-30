[![Build Status](https://travis-ci.org/bonyiii/documentary.svg?branch=master)](https://travis-ci.org/bonyiii/documentary)

# Documentary

Documentary provides "living" API documentation for your application.

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

A param can be:
  - optional
  - required

Param definition consists following elements:

  - Param Name: Name of the argument (compulsory)
    - Can be a symbol or string
  - Keyword arguments (all are optional):
	  - type: Can be anything that respond to ```to_s```
	  - desc: Describe what the given parameter does
	  - if: Response will include the given param if evaluated true
		  -  Expects a symbol or a proc, any kind of authorization logic can be implemented.
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
- [ ] Authorization
- [ ] Swagger compatible output

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Documentary project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/documentary/blob/master/CODE_OF_CONDUCT.md).
