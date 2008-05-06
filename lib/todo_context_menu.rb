module Swat
  class TodoContextMenu
    attr_accessor :todo_menu
    def initialize(title = nil)
      @todo_menu = Gtk::Menu.new
      empty_item = Gtk::MenuItem.new(" ")
      @todo_menu.append(empty_item)
      # @todo_menu.show_all
    end

    def append(title)
      item = Gtk::MenuItem.new(title)
      item.signal_connect("activate") { yield }
      @todo_menu.append(item)
    end

    def show
      @todo_menu.show_all
    end
  end

end
