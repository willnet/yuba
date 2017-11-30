# Yuba

[![Build Status](https://travis-ci.org/willnet/yuba.svg?branch=master)](https://travis-ci.org/willnet/yuba)
[![Gem Version](https://badge.fury.io/rb/yuba.svg)](https://badge.fury.io/rb/yuba)

## warning

This gem is now 0.0.x. It works but there must be occasional breaking changes to the API.

## Summary

Yuba add new layers to rails.

- Service
- Form
- ViewModel

It is convenient to use them in combination, but you can use them even by themselves.

If you have difficulties with large rails application, Yuba help you.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yuba'
```

And then execute:

```bash
$ bundle
```

## Support

- Rails 4.2+
- Ruby 2.2+

## ViewModel

ViewModel is useful when there are many instance variables in controller.

```ruby
class PostViewModel < Yuba::ViewModel
  property :post
  property :author, public: true
  property :other, optional: true

  def title
    post.title
  end

  def body
    post.body
  end
end

Post = Struct.new(:title, :body)
post = Post.new('hello', 'world')

view_model = PostViewModel.new(post: post, author: 'willnet')
view.title #=> 'hello'
view.body #=> 'world'
view.author #=> 'willnet'
view.post #=> NoMethodError
```

### property

`.property` method register property to the class.

Those registered by property need to be passed as arguments to the `initialize` except when `optional: true` is attached. You get ArgumentError if you don't pass `property` to `initialize`.

Property is default to private. This means you can use it in internal the instance. If you it as public, use `public: true` option.

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

In view template, if you want to access user and post, you have to use `@view_model` instance variable like `@view_model.user.name`. if it feels troublesome, you can write like following

```ruby
view_model = ArtistViewModel.new(user: current_user)
render view_model: view_model
```

view_model option of render takes ViewModel, which get it's public methods (include public property) and assign them to instance variables in view template. So you can write `<%= @user.name %>`

## Service

Service is useful when controller has many application logic.

```ruby
class PostController < ApplicationController
  def new
    @post = CreatePostService.call(user: current_user).post
  end

  def create
    service = CreatePostService.call(user: current_user, params: params)

    if service.success?
      redirect_to root_path
    else
      @post = service.post
      render :new
    end
  end
end

class CreatePostService < Yuba::Service
  property :user, public: true
  property :params, optional: true

  def call
    if post.save
      notify_to_admin
    else
      fail!
    end
  end

  def post
    user.posts.build(post_params)
  end

  private

  def notify_to_admin
    AdminMailer.notify_create_post(post).deliver_later
  end

  def post_params
    params.require(:post).permit(:title, :body)
  end
end
```

- `.property` method register property to the class like ViewModel.
- `.call` invokes `#call` after assign arguments to properties.
- `#success?` returns `true` if you don't invoke `#fail!`

## Form

Form is now just wrapper of [reform-rails](https://github.com/trailblazer/reform-rails).

You can see documentation [here](http://trailblazer.to/gems/reform/rails.html).

## Combination Sample

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
      fail!
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
  property :name

  validates :name, presence: true, length: { maximum: 100 }
end
```

```ruby
class Artist::CreateViewModel < Yuba::ViewModel
  property :form, public: true
end
```

## generators

You can use generators.

```
rails generate yuba:service create_artist
rails generate yuba:form artist
rails generate yuba:view_model artist_index
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
