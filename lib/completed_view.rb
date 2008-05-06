module Swat
  class CompletedView
    include Swat::ListHelper
    attr_accessor :todo_data,:parent_view,:list_view
    def initialize(done_view,parent_view)
      @todo_data = parent_view.todo_data
      @list_view = done_view
      @parent_view = parent_view
      @model = create_model(false)
      load_available_lists
      add_columns
      @list_view.expand_all
    end

    def reload_view
      @todo_data = parent_view.todo_data
      @model = create_model(false)
      load_available_lists
      @list_view.expand_all
    end
  end
end
