require "English"
require "mkmf"
require "ftools"
require "rbconfig"
=begin
extconf.rb for Ruby/GTK extention library
=end

PACKAGE_NAME = "gtk2"
PKG_CONFIG_ID = "gtk+-2.0"

require 'mkmf-gnome2'

#
# detect GTK+ configurations
#

PKGConfig.have_package('gthread-2.0')
PKGConfig.have_package(PKG_CONFIG_ID) or exit 1
setup_win32(PACKAGE_NAME)

STDOUT.print("checking for target... ")
STDOUT.flush
target = PKGConfig.variable(PKG_CONFIG_ID, "target")
$defs << "-DRUBY_GTK2_TARGET=\\\"#{target}\\\""
STDOUT.print(target, "\n")

#
# detect location of GDK include files
#
gdkincl = nil
tmpincl = $CFLAGS.gsub(/-D\w+/, '').split(/-I/) + ['/usr/include']
tmpincl.each do |i|
  i.strip!

  if FileTest.exist?(i + "/gdk/gdkkeysyms.h")
    gdkincl = i + "/gdk"
    break
  end
end
raise "can't find gdkkeysyms.h" if gdkincl.nil?

have_func('gtk_plug_get_type')
have_func('gtk_socket_get_type')
have_func('pango_render_part_get_type')

if target=="x11"
  have_func("XReadBitmapFileData")
  have_header('X11/Xlib.h')
  have_func("XGetErrorText")
end

PKGConfig.have_package('gtk+-unix-print-2.0')

have_func('gtk_print_unix_dialog_get_type')
have_func('gtk_print_job_get_type')
have_func('gtk_printer_get_type')
have_func('gtk_page_setup_unix_get_type')

PKGConfig.have_package('cairo')
if have_header('rb_cairo.h')
  if /mingw|cygwin|mswin32/ =~ RUBY_PLATFORM
    unless ENV["CAIRO_PATH"]
      puts "Error! Set CAIRO_PATH."
      exit 1
    end
    add_depend_package("cairo", "packages/cairo/ext", ENV["CAIRO_PATH"])
    $defs << "-DRUBY_CAIRO_PLATFORM_WIN32"
  end
end


#
# create Makefiles
#

add_distcleanfile("rbgdkkeysyms.h")
add_distcleanfile("rbgtkinits.c")


$defs.delete("-DRUBY_GTK2_COMPILATION")

create_makefile("keybinder")

