require 'sketchup.rb'
require 'extensions.rb'

# Skit it a bundle of extensions?
module Skit
  # Load Extension
  unless file_loaded?(__FILE__)
    ex = SketchupExtension.new('Skit', 'skit/main')
    ex.creator = 'Quint Daenen'
    Sketchup.register_extension(ex, true)
    file_loaded(__FILE__)
  end

  # Menu contains the Toolbar/Menu structures.
  module Menu
    plugins_menu = UI.menu('Plugins')
    submenu = plugins_menu.add_submenu('Skit')
    submenu.add_item('Connect') do
      LineTools.connect
    end
    submenu.add_item('Join') do
      LineTools.join
    end
  end
end
