# Yuba

This gem is now under construction. It doesn't work now.

Yuba add new layers to rails.

- Service
- Form
- ViewModel

## Usage

sample

```ruby
class ArtistsController < ApplicationController
  def create
    @model = Artist::CreateService.call(params)

    if @model.success?
      redirect_to artists_path
    else
      render :new
    end
  end
```

```ruby
class Artist::CreateService < Crepe::Service
  def call(params)
    form = build_form(params: params)
    if form.save
      success(form: form) # return ArtistViewModel
    else
      failure(form: form) # return ArtistViewModel
    end
  end
end
```

```ruby
class ArtistForm < Crepe::Form
  model :artist

  attribute :artist do
    attribute :name
    validates :name, presence: true
  end

  collection :albums do
    attribute :title
    attribute :published_on, :date

    validates :title, presence: true
    validates :published_on, presence: true
  end
end
```

```ruby
class ArtistViewModel < Yuba::ViewModel
end
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
