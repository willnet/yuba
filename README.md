# Yuba

[![Build Status](https://travis-ci.org/willnet/yuba.svg?branch=master)](https://travis-ci.org/willnet/yuba)
[![Gem Version](https://badge.fury.io/rb/yuba.svg)](https://badge.fury.io/rb/yuba)

This gem is now under construction. It doesn't work now.

Yuba add new layers to rails.

- Service
- Form
- ViewModel

## Sample

```ruby
class ArtistsController < ApplicationController
  def new
    @view_model = Artist::CreateService.new(params: params).view_model
  end

  def create
    service = Artist::CreateService.call(params: params)

    if service.success?
      redirect_to artists_path
    else
      @view_model = service.view_model
      render :new
    end
  end
```

```ruby
class Artist::CreateService < Yuba::Service
  property :params

  def call
    if form.validate(params)
      form.save
    else
      failure
    end
  end

  def view_model
    Artist::CreateViewModel.new(form: form)
  end

  private

  def form
    @form ||= ArtistForm.new(Artist.new)
  end
end
```

```ruby
class ArtistForm < Yuba::Form
  property :title

  validates :title, presence: true, length: { maximum: 100 }
end
```

```ruby
class Artist::CreateViewModel < Yuba::ViewModel
  property :form, public: true
end
```

## generators

You can use generators.

Example

```sh
rails generate yuba:service create_artist
rails generate yuba:form artist
rails generate yuba:view_model artist_index
```

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'yuba'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install yuba
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
