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

Include Documentar in your controller:


``` ruby
class ApplicationController < ActionController::Base
  include Documentary::Params
  protect\_from\_forgery
end
```

You can define params for each action in your controller:

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

By default param names should be symbols but strings are allowed too.
A param can be:
  - optional
  - required

A param definition consist the following elements:

  - name: Name of the argument (compulsory)
  - Keyword arguments (all are optional):
	  - type: Can be anything that respond to to_s
	  - desc: Describe what the given parameter does
	  - if: Response will include the given param if evaluated true
		  -  Expects a symbol or a proc, any kind of authorization logic can be implemented.
		  - For proc will receive controller instance as input parameter.
		  - For symbol it will call an instance method with that name on the controller

## Compatibility


- [X] Strong Paramters
- [ ] Authorization
- [ ] Swagger compatible output

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Documentary project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/documentary/blob/master/CODE_OF_CONDUCT.md).
