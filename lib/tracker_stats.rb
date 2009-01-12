module Swat
  class TrackerStatBox
    attr_accessor :drawing_area
    def initialize container_frame,drawing_area
      @container_frame = container_frame
      @container_frame.label = "Time Tracker stats"
      @drawing_area = drawing_area
      drawing_area.signal_connect("expose_event") do |widget, event|
        cr = widget.window.create_cairo_context
        cr.scale(*widget.window.size)
        cr.set_line_width(0.04)

        cr.save do
          cr.set_source_color(Gdk::Color.new(65535, 65535, 65535))
          cr.gdk_rectangle(Gdk::Rectangle.new(0, 0, 1, 1))
          cr.fill
        end
        draw(cr)
      end
    end

    def draw(cr)
      cr.set_line_width(0.02)

      #cr.set_line_cap(Cairo::LINE_CAP_BUTT) # default
      #cr.
      cr.move_to(0.02, 0.02)
      #cr.line_to(0.05, 0.01)
      cr.set_source_rgb(0,0.4,0.5)
      cr.rectangle(0.02, 0.02, 0.4, 0.02)
      cr.fill

#       cr.select_font_face("Sans",Cairo::FONT_SLANT_NORMAL,
#                           Cairo::FONT_WEIGHT_NORMAL)
      cr.set_font_size(0.02)
      cr.move_to(0.02,0.06)
      cr.set_source_rgb(0,0,0)
      cr.show_text("hello world")
      cr.fill

#       cr.set_line_cap(Cairo::LINE_CAP_ROUND)
#       cr.move_to(0.5, 0.2)
#       cr.line_to(0.5, 0.8)
#       cr.stroke

#       cr.set_line_cap(Cairo::LINE_CAP_SQUARE)
#       cr.move_to(0.75, 0.2)
#       cr.line_to(0.75, 0.8)
#       cr.stroke

#       # draw helping lines
#       cr.set_source_rgba(1, 0.2, 0.2)
#       cr.set_line_width(0.01)

#       cr.move_to(0.25, 0.2)
#       cr.line_to(0.25, 0.8)

#       cr.move_to(0.5, 0.2)
#       cr.line_to(0.5, 0.8)

#       cr.move_to(0.75, 0.2)
#       cr.line_to(0.75, 0.8)

#       cr.stroke
    end

  end
end
