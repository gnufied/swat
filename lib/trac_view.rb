# class defines a viewer of your trac tickets

module Swat
  class TracView
    include Swat::ListHelper
    def load_rss
      @config_dir = File.join(ENV['HOME'] + '/.swat')
      @config_file = File.join(@config_dir,"parameters.yml")
      @feed_url = @config_file['trac_url']
      @trac_username = @config_file['trac_username']
      @trac_password = @config_file['trac_password']
      @rss_content = nil
      open(@feed_url,:http_basic_authentication => [@trac_username,@trac_password]) { |s| @rss_content = s.read }
      @rss = RSS::Parser.parse(@rss_content,false)
    end
    
    # will convert rss data to swap format
    def convert_rss_to_swap_data
    
    end
  end
end


