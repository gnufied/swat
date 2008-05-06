module Swat
  class AddTodoDialog
    attr_accessor :todo_glade,:add_dialog
    def initialize(old_categories,&block)
      @old_categories = old_categories
      @add_callback = block
      @todo_glade = GladeXML.new("#{SWAT_APP}/resources/add_todo.glade") { |handler| method(handler) }
      @add_dialog = @todo_glade.get_widget("add_todo_dialog")
      @todo_text_entry = @todo_glade.get_widget("todo_text_entry")
      @category_combo = @todo_glade.get_widget("todo_category_entry")
      @priority_combo = @todo_glade.get_widget("priority_combo")
      populate_old_categories
      @add_dialog.show_all
    end

    def populate_old_categories
      model = Gtk::ListStore.new(String)
      @category_combo.model = model
      @category_combo.text_column = 0
      @old_categories.each do |x|
        iter = model.append
        iter[0] = x
      end
    end

    def on_add_todo_button_activate
      @add_callback.call(@priority_combo.active_text,@category_combo.child.text,@todo_text_entry.buffer.text)
      @add_dialog.destroy
    end

    def on_button2_clicked
      @add_dialog.destroy
    end
  end
end

