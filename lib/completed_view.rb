module Swat
  class CompletedView
    include Swat::ListHelper
    attr_accessor :todo_data,:parent_view,:list_view
    def initialize(done_view,parent_view)
      @todo_data = parent_view.todo_data
      @list_view = done_view
      @parent_view = parent_view
      # will create an model with completed tasks
      @model = create_model(false)
      load_available_lists
      add_columns
      connect_custom_signals
      @list_view.expand_all
    end

    def reload_view
      @todo_data = parent_view.todo_data
      @model = create_model(false)
      load_available_lists
      @list_view.expand_all
    end

    def connect_custom_signals
      @completed_context_menu = TodoContextMenu.new
      @completed_context_menu.append(" Remove Task ") { remove_task }
      @completed_context_menu.show
      @list_view.signal_connect("button_press_event") do |widget,event|
        if event.kind_of? Gdk::EventButton and event.button == 3
          @completed_context_menu.todo_menu.popup(nil, nil, event.button, event.time)
        end
      end
      @list_view.signal_connect("popup_menu") { @completed_context_menu.todo_menu.popup(nil, nil, 0, Gdk::Event::CURRENT_TIME) }
    end

    def remove_task
      selection = @list_view.selection
      if iter = selection.selected
        selected_category = iter.parent[0]
        task_index = iter[3]
        @todo_data.remove(selected_category,task_index)
        @list_view.model.remove(iter)
        @todo_data.dump
      end
    end # end of remove_task

  end
end
