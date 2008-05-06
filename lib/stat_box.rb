module Swat
  class StatBox
    attr_accessor :meta_data,:vbox_container
    def initialize(meta_data)
      @meta_data = meta_data
      @vbox_container = Gtk::VBox.new
      stat_label = Gtk::Label.new
      stat_label.xalign = 0.02
      stat_label.set_markup("<span underline='double' weight='bold' style='oblique'> Stats </span>\n")

      @vbox_container.pack_start(stat_label,false,false)

      set_today_label
      @vbox_container.pack_start(@today_label,false,false)

      set_yesterday_label
      @vbox_container.pack_start(@yesterday_label,false,false)

      set_lastweek_label
      @vbox_container.pack_start(@lastweek_label,false,false)
    end

    def set_today_label(p_meta_data = nil)
      @meta_data = p_meta_data if p_meta_data
      today_heading = Gtk::Label.new
      today_heading.xalign = 0.02
      today_heading.set_markup("<span foreground='#6d0835' style='oblique' > Today </span>")
      @vbox_container.pack_start(today_heading,false,false)

      @today_label = Gtk::Label.new
      @today_label.xalign = 0
      today_str = <<-EOD
    <small> Done : <span foreground='#206d08'>#{@meta_data.tasks_done_today}</span>, Added : <span foreground='red'>#{@meta_data.tasks_added_today}</span> </small>
    EOD
      @today_label.set_markup(today_str)
    end

    def update_today_label(p_meta_data = nil)
      @meta_data = p_meta_data if p_meta_data
      today_str = <<-EOD
    <small> Done : <span foreground='#206d08'>#{@meta_data.tasks_done_today}</span>, Added : <span foreground='red'>#{@meta_data.tasks_added_today}</span> </small>
    EOD
      @today_label.set_markup(today_str)
    end

    def show_all
      @vbox_container.show_all
    end

    def hide_all
      @vbox_container.hide_all
    end

    def set_yesterday_label
      yesterday_heading = Gtk::Label.new
      yesterday_heading.xalign = 0.02
      yesterday_heading.set_markup("<span foreground='#6d0835' style='oblique'> Yesterday </span>")
      @vbox_container.pack_start(yesterday_heading,false,false)

      @yesterday_label = Gtk::Label.new
      @yesterday_label.xalign = 0
      yesterday_str = <<-EOD
    <small> Done : <span foreground='#206d08'>#{@meta_data.tasks_done_yesterday}</span>, Added : <span foreground='red'>#{@meta_data.tasks_added_yesterday}</span> </small>
    EOD
      @yesterday_label.set_markup(yesterday_str)
    end

    def set_lastweek_label
      lastweek_heading = Gtk::Label.new
      lastweek_heading.xalign = 0.02
      lastweek_heading.set_markup("<span foreground='#6d0835' style='oblique'> Lastweek </span>")
      @vbox_container.pack_start(lastweek_heading,false,false)

      @lastweek_label = Gtk::Label.new
      @lastweek_label.xalign = 0
      lastweek_str = <<-EOD
    <small> Done : <span foreground='#206d08'> #{@meta_data.tasks_done_lastweek} </span>, Added : <span foreground='red'> #{@meta_data.tasks_added_lastweek}</span> </small>
    EOD
      @lastweek_label.set_markup(lastweek_str)
    end
  end
end

