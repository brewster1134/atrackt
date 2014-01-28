source 'https://rubygems.org'

group :development do
  gem 'guard'
  gem 'guard-coffeescript'
  gem 'json', '~> 1.7.7'
end

# Platform specific gems (set `require: false`)
group :development do
  gem 'rb-fsevent', require: false
  gem 'growl', require: false
  gem 'terminal-notifier-guard', require: false
end

# OS X
if RUBY_PLATFORM.downcase =~ /darwin/
  require 'rb-fsevent'

  # 10.8 Mountain Lion
  if RUBY_PLATFORM.downcase =~ /darwin12/
    require 'terminal-notifier-guard'

  # 10.7 Lion and below
  else
    require 'growl'
  end
end
