$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'walle'
require 'rspec/collection_matchers'

Dir['./spec/support/**/*.rb'].each { |f| require f }

RSpec.configure do |c|
  c.include Walle::Matchers

  c.order = 'random'
end
