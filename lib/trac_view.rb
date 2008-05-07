# class defines a viewer of your trac tickets

module Swat
  class TracView
    include Swat::ListHelper
    attr_accessor :todo_data,:parent_view

    def initialize trac_view_widget,parent_widget
      @parent_view = parent_widget
      @list_view = trac_view_widget
      @todo_data = TodoData.new(nil)
      @rss_data = load_rss
      @todo_data.load_rss_data @rss_data
      @model = create_model
      load_available_lists
      add_columns
      connect_custom_signals
      @list_view.expand_all
    end

    def load_rss
      @config_dir = File.join(ENV['HOME'] + '/.swat')
      @config_file = YAML.load(File.open(File.join(@config_dir,"parameters.yml"),"r"))
      @feed_url = @config_file['trac_url']
      @trac_username = @config_file['trac_username']
      @trac_password = @config_file['trac_password']
      @rss_content = nil
      open(@feed_url,:http_basic_authentication => [@trac_username,@trac_password]) { |s| @rss_content = s.read }
      rss = RSS::Parser.parse(@rss_content,false)
      return rss
    end

    def refresh_data
      @rss_data = load_rss
      @todo_data.load_rss_data @rss_data
      reload_view
    end

    def connect_custom_signals
      @trac_view_context_menu = TodoContextMenu.new
      @trac_view_context_menu.append(" Add to Today\'s Agenda ") { add_to_active }
      @trac_view_context_menu.show
      @list_view.signal_connect("button_press_event") do |widget,event|
        if event.kind_of? Gdk::EventButton and event.button == 3
          @trac_view_context_menu.todo_menu.popup(nil,nil,event.button,event.time)
        end
      end
      @list_view.signal_connect("popup_menu") { @trac_view_context_menu.todo_menu.popup(nil, nil, 0, Gdk::Event::CURRENT_TIME) }
    end # end of connect custom signals method

    def add_to_active
      selection = @list_view.selection
      if iter = selection.selected
        selected_category = iter.parent[0]
        task_index = iter[3]
        priority = todo_data.get_priority(selected_category,task_index)
        task_text = todo_data.get_task(selected_category,task_index)
        @parent_view.add_to_tasklist(priority,selected_category,task_text)
        @list_view.model.remove(iter)
      end
    end # end of add_to_active method
  end # end of class TracView
end # end of module Swat


