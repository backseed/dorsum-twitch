require "spec"
require "webmock"

require "../src/dorsum"
require "./mocks/client"

Spec.before_each do
  WebMock.reset
end
