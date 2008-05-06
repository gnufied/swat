module Swat
  class SwatMetaData
    attr_accessor :meta_data
    attr_accessor :meta_data_file_location,:todo_file

    def initialize(config_file)
      @meta_data_file_location = config_file
      if File.exists?(@meta_data_file_location)
        @meta_data = YAML.load(ERB.new(IO.read(config_file)).result) || { }
      else
        @meta_data = {}
      end
    end

    def todo_added
      @meta_data[current_time] ||= {:tasks_added => 0, :tasks_done => 0 }
      @meta_data[current_time][:tasks_added] += 1
    end

    def todo_done
      @meta_data[current_time] ||= {:tasks_added => 0, :tasks_done => 0 }
      @meta_data[current_time][:tasks_done] += 1
    end

    def tasks_added_today;
      @meta_data[current_time] ? @meta_data[current_time][:tasks_added] : 0
    end

    def tasks_done_today
      @meta_data[current_time] ? @meta_data[current_time][:tasks_done] : 0
    end

    def tasks_added_yesterday
      @meta_data[yesterday] ? @meta_data[yesterday][:tasks_added] : 0
    end

    def tasks_done_yesterday
      @meta_data[yesterday] ? @meta_data[yesterday][:tasks_done] : 0
    end

    def tasks_added_lastweek
      lastweek.inject(0) { |mem,obj| mem += (@meta_data[obj] ? @meta_data[obj][:tasks_added] : 0) }
    end

    def tasks_done_lastweek
      lastweek.inject(0) { |mem,obj| mem += (@meta_data[obj] ? @meta_data[obj][:tasks_done] : 0) }
    end

    def current_time; Time.now.strftime("%Y-%m-%d"); end
    def yesterday;
      (Time.now - 24*3600).strftime("%Y-%m-%d")
    end

    def lastweek; (0..6).to_a.map { |i| (Time.now - i*24*3600).strftime("%Y-%m-%d")}; end

    # method dumps data to file
    def dump
      File.open(@meta_data_file_location,'w') { |f| f.write(YAML.dump(@meta_data))}
    end
  end
end
