require 'sketchup.rb'
require 'extensions.rb'

module Skit
  # Example Extension Header
  module Example
    unless file_loaded?(__FILE__)
      ex = SketchupExtension.new('Example', 'example/main')
      Sketchup.register_extension(ex, true)
      file_loaded(__FILE__)
    end
  end
end
