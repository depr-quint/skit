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
    menu = UI.menu('Plugins')
    submenu = menu.add_submenu('Skit')
    submenu.add_item('Join') do
      LineTools.join
    end

    toolbar = UI::Toolbar.new('Join')
    join = UI::Command.new('Join') do
      puts File.join(File.dirname(__FILE__), 'skit', 'images', 'join.svg')
      LineTools.join
    end
    join.menu_text = 'Join'
    join.large_icon = join.small_icon = File.join(File.dirname(__FILE__), 'skit', 'images', 'join.svg')
    toolbar = toolbar.add_item(join)
    toolbar.show
  end
end