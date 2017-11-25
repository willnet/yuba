# Yuba

[![Build Status](https://travis-ci.org/willnet/yuba.svg?branch=master)](https://travis-ci.org/willnet/yuba)
[![Gem Version](https://badge.fury.io/rb/yuba.svg)](https://badge.fury.io/rb/yuba)

This gem is now under construction. It doesn't work now.

Yuba add new layers to rails.

- Service
- Form
- ViewModel

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

## ViewModel

ViewModel is useful when there are many instance variables in controller.

### Auto Assign

You can use ViewModel like following

```ruby
class ArtistViewModel < Yuba::ViewModel
  property :user, public: true

  def post
    user.latest_post
  end
end

@view_model = ArtistViewModel.new(user: current_user)
```

In view template, if you want to access user and post, you have to use `@view_model` instance variable like `@view_model.user.name`. if you feel that it's troublesome, you can write like following

```ruby
view_model = ArtistViewModel.new(user: current_user)
render view_model: view_model
```

view_model option takes ViewModel get it's public methods and assign them to instance variables in view template. So you can write `<%= @user.name %>`

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



## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
