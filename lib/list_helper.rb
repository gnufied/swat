module Swat
  module ListHelper
    def reload_view
      @model = create_model
      load_available_lists
      @list_view.expand_all
    end

    def load_available_lists
      @list_view.model = @model
      @list_view.rules_hint = false
      @list_view.selection.mode = Gtk::SELECTION_SINGLE
    end
    def add_columns
      model = @list_view.model
      renderer = Gtk::CellRendererText.new
      renderer.xalign = 0.0

      col_offset = @list_view.insert_column(-1, 'Category', renderer, 'text' => 0,'background' => 1,:weight => 2)
      column = @list_view.get_column(col_offset - 1)
      column.clickable = true
      @list_view.expander_column = column
    end

    def create_model(open_task = true)
      model = Gtk::TreeStore.new(String,String,Fixnum,Fixnum)
      populate_model = lambda do |key,value|
        iter = model.append(nil)
        iter[0] = key
        iter[1] = "white"
        iter[2] = 900
        iter[3] = 0
        value.each do |todo_item|
          child_iter = model.append(iter)
          child_iter[0] = wrap_line(todo_item.text)
          child_iter[1] = chose_color(todo_item)
          child_iter[2] = 500
          child_iter[3] = todo_item.index
        end
      end

      if(open_task)
        todo_data.open_tasks(&populate_model)
      else
        todo_data.close_tasks(&populate_model)
      end
      return model
    end

    def wrap_line(line)
      line_array = []
      loop do
        first,last = line.unpack("a90a*")
        first << "-" if last =~ /^\w/
        line_array << first
        break if last.empty?
        line = last
      end
      return line_array.join("\n")
    end

    def chose_color(todo_item)
      case todo_item.priority
      when 1: 'yellow'
      when 0: 'blue'
      when 2: '#E3B8B8'
      when 3: '#15B4F1'
      when 4: '#F1F509'
      end
    end
  end
end
