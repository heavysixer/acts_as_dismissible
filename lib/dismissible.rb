module Dismissible
  module Controller  
    def self.included(base)
      base.send :helper_method, :cookies
    end
  end
  
  module Helpers
    def dismissible_message(id, opts={}, &block)
      opts.reverse_merge!({ 
        :message => "Don't show this again.", 
        :class => "dismissible_message", 
        :dismiss_button => nil,
        :follows => nil,
        :callback => nil,
        :style => "" })
      id = "hide_dismissible_#{id}"
      
      return if cookies[id]
      
      return if opts[:follows] && !cookies["hide_dismissible_#{opts[:follows]}"]
      dismissible_content = capture(&block)
      
      concat(content_tag(:div, 
        dismissible_content + %{#{link_to_dismiss(id,opts)} #{dismissible_script(id, opts)}}, 
        :class => opts[:class], :style => opts[:style], :id => id))    
    end
    
    def link_to_dismiss(id, opts)
      opts[:expires] = CGI.rfc1123_date(5.years.from_now) # Cookie expires 5 years in the future.
      href = link_to_function(opts[:message], "dismiss_window_#{id}()", { :class => "dismissible_link" })
      "<p>#{href}</p>" if opts[:dismiss_button].nil?
    end
    
    def dismissible_script(id, opts)
      callback = opts[:callback].nil? ? "document.getElementById('#{id}').style.display = 'none'" : "#{opts[:callback]}('#{id}')"
      javascript_tag(%Q{
        function dismiss_window_#{id}() {
          document.cookie = '#{id}=1; expires=#{opts[:expires]}; path=/';
          #{callback};
        }
      })
    end
  end
end