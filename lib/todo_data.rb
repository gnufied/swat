module Swat
  class TodoData
    attr_accessor :config_file,:todo_container
    def initialize(config_file)
      @config_file = config_file
      @todo_container = {}
      parse_file_data if @config_file && File.exist?(@config_file)
    end

    def load_rss_data rss_data
      @todo_container['trac_ticket'] = []
      if rss_data
        item_count = rss_data.items.size
        item_count.times do |index|
          #item_text = rss_data.items[index].title + " : <a href=\"" + rss_data.items[index].link
          item_text = <<-EOD
#{rss_data.items[index].title} : posted #{time_ago(rss_data.items[index].date)} ago
        EOD
          item = OpenStruct.new(:priority => 2,:flag => true,:text => item_text,:index => index,:link => rss_data.items[index].link)
          @todo_container['trac_ticket'] << item
        end

      end
    end

    def time_ago date
      day_diff = ((Time.now - date)/(24*3600)).floor
      return "#{day_diff} days" if day_diff > 1
      hour_diff = ((Time.now - date)/3600).floor
      return "#{hour_diff} hours" if hour_diff > 1
      min_diff = ((Time.now - date)/60).floor
      return "#{min_diff} minutes"
    end

    # will read the relevant todo data file and load the todo list
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

    # will return open_tasks
    def open_tasks
      @todo_container.each do |category,todo_array|
        next if todo_array.empty?
        sorted_array = todo_array.sort { |x,y| x.priority <=> y.priority }
        open_task_array = sorted_array.reject { |x| !x.flag }
        next if open_task_array.empty?
        yield(category,open_task_array)
      end
    end

    # will return closed tasks
    def close_tasks
      @todo_container.each do |category,todo_array|
        next if todo_array.empty?
        sorted_array = todo_array.sort! { |x,y| x.priority <=> y.priority }
        done_task_array = sorted_array.reject { |x| x.flag }
        next if done_task_array.empty?
        yield(category,done_task_array)
      end
    end

    # will dump the todo data in memory to a file
    def dump
      return unless @config_file
      File.open(@config_file,'w') do |fl|
        @todo_container.each do |category,todo_array|
          fl << "* #{category}\n"
          todo_array.each do |todo_item|
            fl << "#{priority_star(todo_item.priority)} #{todo_item.flag ? 'TODO' : 'DONE'} #{todo_item.text}\n"
          end
        end
      end
    end

    # will return priority of the task
    def priority_star(count)
      foo = ''
      count.times { foo << '*'}
      return foo
    end

    # will delete the task from internal memory respresentation
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

    # will return the available categories
    def categories
      return @todo_container.keys
    end

    # will insert new task
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

    def get_trac_url task_index
      result = @todo_container['trac_ticket'].detect { |x| x.index == task_index }
      result.link
    end

    def get_task(category,task_index)
      result = @todo_container[category].detect { |x| x.index == task_index }
      return result.text
    end

  end
end

