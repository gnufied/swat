module Swat
  class TodoWindow
    include Swat::ListHelper
    attr_accessor :todo_data,:glade,:todo_window,:todo_notebook,:status

    TreeItem = Struct.new('TreeItem',:description, :priority,:category)
    @@todo_file_location = nil
    @@meta_data_file = nil
    @@wish_list = nil

    def self.meta_data_file= (file); @@meta_data_file = file; end
    def self.todo_file_location= (filename); @@todo_file_location = filename; end
    def self.wishlist= (filename); @@wishlist = filename; end

    def on_todo_window_delete_event
      hide_window
      return true
    end

    def on_todo_window_destroy_event; return true; end

    def on_add_todo_button_clicked
      all_categories = (@todo_data.categories + @wish_list_tab.todo_data.categories).uniq
      AddTodoDialog.new(all_categories) do |priority,agenda_category,category,todo|
        chose_and_add(priority,agenda_category,category,todo)
      end
    end

    def chose_and_add(priority,agenda_category,category,todo)
      if agenda_category == 1
        @wish_list_tab.add_to_wishlist(category,todo,priority)
        @todo_notebook.page = 1
      else
        add_to_tasklist(priority,category,todo)
      end
    end

    def add_to_tasklist(priority,category,todo)
      @todo_data.insert(category,todo,priority.to_i)
      @meta_data.todo_added
      @meta_data.dump
      @todo_data.dump
      reload_view
      @stat_vbox.update_today_label(@meta_data)
      @todo_notebook.page = 0
    end

    def on_toggle_stat_button_clicked
      # stat box is hidden
      unless @stat_box_status
        button_icon_widget = Gtk::Image.new("#{SWAT_APP}/resources/control_end_blue.png")
        @stat_vbox.show_all
        # stat box is already shown
      else
        button_icon_widget = Gtk::Image.new("#{SWAT_APP}/resources/control_rewind_blue.png")
        @stat_vbox.hide_all
      end
      @stat_box_status = !@stat_box_status
      @stat_toggle_button.image = button_icon_widget
    end

    def on_todo_window_key_press_event(widget,key)
      hide_window if Gdk::Keyval.to_name(key.keyval) =~ /Escape/i
    end

    # should take current tab into account and refresh the view
    def on_reload_button_clicked
      page_number = @todo_notebook.page
      case page_number
      when 0
        @todo_data = TodoData.new(@@todo_file_location)
        reload_view
      when 1
        @wish_list_tab.refresh_data
      when 2
        @done_tab.reload_view
      when 3
        @trac_tab.refresh_data
      else
        puts "Invalid page"
      end
    end


    def initialize path
      @glade = GladeXML.new(path) { |handler| method(handler) }
      @list_view = @glade.get_widget("todo_view")
      @todo_notebook = @glade.get_widget("todo_notebook")
      @todo_window = @glade.get_widget("todo_window")
      window_icon = Gdk::Pixbuf.new("#{SWAT_APP}/resources/todo.png")
      @todo_window.icon_list = [window_icon]
      @todo_window.title = "Your TaskList"
      @todo_selection = @list_view.selection
      @todo_selection.mode = Gtk::SELECTION_SINGLE

      @meta_data = SwatMetaData.new(@@meta_data_file)
      #layout_statbar
      @todo_data = TodoData.new(@@todo_file_location)
      @model = create_model
      load_available_lists
      add_columns
      connect_custom_signals
      layout_wishlist
      layout_done_view
      layout_trac_view
      @list_view.expand_all
      @status = false
      @todo_window.hide
    end

    # layout statistic bar
    # def layout_statbar
#       @stat_toggle_button = @glade.get_widget("toggle_stat_button")
#       @stat_hbox = @glade.get_widget("stat_box")
#       @stat_vbox = StatBox.new(@meta_data)

#       @stat_hbox.pack_end(@stat_vbox.vbox_container,true)
#       button_icon_widget = Gtk::Image.new("#{SWAT_APP}/resources/control_rewind_blue.png")
#       @stat_box_status = false
#       @stat_toggle_button.image = button_icon_widget
#     end

    def layout_wishlist
      wish_list_view = @glade.get_widget("wish_list_view")
      @wish_list_tab = WishList.new(@@wishlist,wish_list_view,self)
    end

    def layout_done_view
      done_view = @glade.get_widget("done_view")
      @done_tab = CompletedView.new(done_view,self)
    end

    #will layout trac view
    #commenting this out because it won't work while starting
    def layout_trac_view
      trac_view = @glade.get_widget("trac_view")
      @trac_tab = TracView.new(trac_view,self)
    end

    def connect_custom_signals
      @todo_context_menu = TodoContextMenu.new
      @todo_context_menu.append(" Mark As Done ") { mark_as_done }
      @todo_context_menu.append(" Add back to Open Tasks ") { mark_as_wishlist }
      @todo_context_menu.show

      @list_view.signal_connect("button_press_event") do |widget,event|
        if event.kind_of? Gdk::EventButton and event.button == 3
          @todo_context_menu.todo_menu.popup(nil, nil, event.button, event.time)
        end
      end
      @list_view.signal_connect("popup_menu") { @todo_context_menu.todo_menu.popup(nil, nil, 0, Gdk::Event::CURRENT_TIME) }

      # FIXME: implement fold and unfold of blocks
      @list_view.signal_connect("key-press-event") do |widget,event|
        if event.kind_of? Gdk::EventKey
          key_str = Gdk::Keyval.to_name(event.keyval)
          if key_str =~ /Left/i
            # fold the block
          elsif key_str =~ /Right/i
            # unfold the block
          end
        end
      end
    end

    def mark_as_done
      selection = @list_view.selection
      if iter = selection.selected
        selected_category = iter.parent[0]
        task_index = iter[3]
        @todo_data.delete(selected_category,task_index)
        @list_view.model.remove(iter)
        @todo_data.dump
        @meta_data.todo_done
        @meta_data.dump
        @stat_vbox.update_today_label(@meta_data)
        @done_tab.reload_view
      end
    end

    def mark_as_wishlist
      selection = @list_view.selection
      if iter = selection.selected
        selected_category = iter.parent[0]
        task_index = iter[3]
        priority = todo_data.get_priority(selected_category,task_index)
        task_text = todo_data.get_task(selected_category,task_index)
        @wish_list_tab.add_to_wishlist(selected_category,task_text,priority)
        @todo_data.remove(selected_category,task_index)
        @todo_data.dump
        @list_view.model.remove(iter)
      end
    end

    def show_window
      @todo_window = @glade.get_widget("todo_window")
      @todo_window.present
      @todo_window.show
      @status = true
    end

    def hide_window;
      @todo_window.hide
      @status = false
    end

    def on_sync_button_clicked
      system("svn up #{@@todo_file_location}")
      system("svn ci #{@@todo_file_location} -m 'foo'")
    end

  end
end


