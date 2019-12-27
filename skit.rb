# Skit it a bundle of extensions?
module Skit
  # Finds and returns all filenames for the .rb files in the skit folder.
  def self.files
    Dir.glob(File.join(File.join(__dir__, 'skit'), '*', '*.rb')).each { |filename|
      yield filename
    }
  end

  # Loads all extensions.
  files do |filename|
    begin
      $LOAD_PATH << File.dirname(filename)
      require filename
    end
  end

  # Reloads all extensions.
  # Can be called from the Ruby Console in SU: "Skit.reload".
  def self.reload
    load __FILE__
    files do |filename|
      load filename
    end
    puts 'Reloaded Skit Extensions.'
  end

  # Menu contains the Toolbar/Menu structures.
  module Menu
    unless file_loaded?(__FILE__)
      plugins_menu = UI.menu('Plugins')
      submenu = plugins_menu.add_submenu('Skit')
      submenu.add_item('Hello World') {
        UI.messagebox('Hi there!')
      }
      submenu.add_item('Create') do
        Example.create
      end
      file_loaded(__FILE__)
    end
  end
end
