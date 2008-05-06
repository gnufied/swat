# class implement a list view similar to todo window
module Swat
  class WishList
    include Swat::ListHelper
    attr_accessor :wish_list_file, :todo_data
    attr_accessor :parent_view
    def initialize(wish_list_file,wish_list_view,parent_view)
      @parent_view = parent_view
      @list_view = wish_list_view
      @wish_list_file = wish_list_file
      @todo_data = TodoData.new(@wish_list_file)
      @model = create_model
      load_available_lists
      add_columns
      connect_custom_signals
      @list_view.expand_all
    end

    def connect_custom_signals
      @wish_context_menu = TodoContextMenu.new
      @wish_context_menu.append(" Remove Wish ") { remove_wish }
      @wish_context_menu.append(" Add to Active ") { add_to_active }
      @wish_context_menu.show
      @list_view.signal_connect("button_press_event") do |widget,event|
        if event.kind_of? Gdk::EventButton and event.button == 3
          @wish_context_menu.todo_menu.popup(nil, nil, event.button, event.time)
        end
      end
      @list_view.signal_connect("popup_menu") { @wish_context_menu.todo_menu.popup(nil, nil, 0, Gdk::Event::CURRENT_TIME) }
    end

    def remove_wish
      selection = @list_view.selection
      if iter = selection.selected
        selected_category = iter.parent[0]
        task_index = iter[3]
        @todo_data.remove(selected_category,task_index)
        @list_view.model.remove(iter)
        @todo_data.dump
      end
    end

    def add_to_active
      selection = @list_view.selection
      if iter = selection.selected
        selected_category = iter.parent[0]
        task_index = iter[3]
        priority = todo_data.get_priority(selected_category,task_index)
        task_text = todo_data.get_task(selected_category,task_index)
        @parent_view.add_to_tasklist(selected_category,task_text,priority)
        todo_data.remove(selected_category,task_index)
        todo_data.dump
        @list_view.model.remove(iter)
      end
    end

    def add_to_wishlist(category,task,priority)
      @todo_data.insert(category,task,priority.to_i)
      @todo_data.dump
      reload_view
    end
  end
end

