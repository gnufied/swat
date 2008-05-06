module Swat
  class TodoData
    attr_accessor :config_file,:todo_container
    def initialize(config_file)
      @config_file = config_file
      @todo_container = {}
      parse_file_data if File.exist?(@config_file)
    end

    def parse_file_data
      current_category = nil
      todo_lines = []
      File.open(@config_file) {|fl| todo_lines = fl.readlines() }
      line_count = 0
      todo_lines.each do |todo_line|
        todo_line.strip!.chomp!
        next if todo_line.nil? or todo_line.empty?
        case todo_line
        when /^\*{1}\ (.+)?/
          current_category = $1
          line_count = 0
          @todo_container[current_category] ||= []
        when /^(\*{2,})\ TODO\ (.+)?/
          priority = $1.size
          item = OpenStruct.new(:priority => priority, :flag => true, :text => $2,:index => line_count )
          line_count += 1
          @todo_container[current_category] << item
        when /^(\*{2,})\ DONE\ (.+)?/
          priority = $1.size
          item = OpenStruct.new(:priority => priority, :flag => false, :text => $2,:index => line_count )
          line_count += 1
          @todo_container[current_category].push(item)
        end
      end
    end

    def open_tasks
      @todo_container.each do |category,todo_array|
        next if todo_array.empty?
        sorted_array = todo_array.sort { |x,y| x.priority <=> y.priority }
        open_task_array = sorted_array.reject { |x| !x.flag }
        next if open_task_array.empty?
        yield(category,open_task_array)
      end
    end

    def close_tasks
      @todo_container.each do |category,todo_array|
        next if todo_array.empty?
        sorted_array = todo_array.sort! { |x,y| x.priority <=> y.priority }
        done_task_array = sorted_array.reject { |x| x.flag }
        next if done_task_array.empty?
        yield(category,done_task_array)
      end
    end

    def dump
      File.open(@config_file,'w') do |fl|
        @todo_container.each do |category,todo_array|
          fl << "* #{category}\n"
          todo_array.each do |todo_item|
            fl << "#{priority_star(todo_item.priority)} #{todo_item.flag ? 'TODO' : 'DONE'} #{todo_item.text}\n"
          end
        end
      end
    end

    def priority_star(count)
      foo = ''
      count.times { foo << '*'}
      return foo
    end

    def delete(category,task_index)
      @todo_container[category].each do |task_item|
        if task_item.index == task_index
          task_item.flag = false
        end
      end
    end

    def remove(category,task_index)
      @todo_container[category].delete_if { |x| x.index == task_index }
    end

    def categories
      return @todo_container.keys
    end

    def insert(category,task,priority)
      @todo_container[category] ||= []
      last_task = @todo_container[category].last
      next_index = last_task ? (last_task.index + 1): 0
      @todo_container[category] << OpenStruct.new(:priority => priority, :text => task.gsub(/\n/,' '), :flag => true,:index => next_index)
    end

    def get_priority(category,task_index)
      result = @todo_container[category].detect { |x| x.index == task_index }
      result ? result.priority : 2
    end

    def get_task(category,task_index)
      result = @todo_container[category].detect { |x| x.index == task_index }
      return result.text
    end

  end
end

