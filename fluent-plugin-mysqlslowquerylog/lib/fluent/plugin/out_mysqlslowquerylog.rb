class Fluent::MySQLSlowQueryLogOutput < Fluent::Output
  Fluent::Plugin.register_output('mysqlslowquerylog', self)
  include Fluent::HandleTagNameMixin

  def configure(conf)
    super
    @slowlogs = {}
    @slowlogs2 = {}

    @boolRegex0 = false
    @boolRegex1 = false
    @boolRegex2 = false
    @boolRegex3 = false
    @boolRegex4 = false
    @boolRegex5 = false
    @boolRegex6 = false
    @boolRegex7 = false
    @boolRegex8 = false

    if !@remove_tag_prefix && !@remove_tag_suffix && !@add_tag_prefix && !@add_tag_suffix
      raise ConfigError, "out_myslowquerylog: At least one of option, remove_tag_prefix, remove_tag_suffix, add_tag_prefix or add_tag_suffix is required to be set."
    end
  end

  def start
    super
  end

  def shutdown
    super
  end

  def emit(tag, es, chain)
    if !@slowlogs[:"#{tag}"].instance_of?(Array)
      @slowlogs[:"#{tag}"] = []
    end
    es.each do |time, record|

      concat_messages(tag, time, record)
    end

    chain.next
  end

  def concat_messages(tag, time, record)
    #puts "Recordsssssssssssssssssssssssssssssssssssssssssssssssssss " + record.inspect
     
    record.each do |key, value|

      if ! key.eql?("server") 
         @slowlogs[:"#{tag}"] << value
          if  validate(tag, value)
#                puts "NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW " + value
           #puts (@boolRegex0 && @boolRegex1 && @boolRegex2 && @boolRegex3 && @boolRegex4  && @boolRegex6  && @boolRegex7)
#         if value.end_with?(';') && !value.upcase.start_with?('USE ', 'SET TIMESTAMP=')  && !validate(tag)
           parse_message(tag, time, record["server"])
       end
      end
    end
  end
  REGEX1 = /^#? User\@Host:\s+(\S+)\s+\@\s+(\S+).*/
  REGEX2 = /^# Schema:\s+([0-9.a-zA-Z_]*)\s+Last_errno:\s+([0-9.]+)\s+ Killed:\s+([0-9.]+).*/
#  REGEX2 = /^# Query_time: ([0-9.]+)\s+Lock_time: ([0-9.]+)\s+Rows_sent: ([0-9.]+)\s+Rows_examined: ([0-9.]+).*/
  REGEX3 = /^#\s+Query_time:\s+([0-9.]+)\s+Lock_time:\s+([0-9.]+)\s+Rows_sent:\s+([0-9.]+)\s+Rows_examined:\s+([0-9.]+)\s+Rows_affected:\s+([0-9.]+).*/
  REGEX4 = /^#\s+Bytes_sent:\s+([0-9.]+).*/
  REGEX5 = /^use(.+)/
  REGEX6 = /^SET timestamp=(\d+)/
   
  def validate(tag, message)

#puts "ssssssssssssssssssssss" +  @slowlogs.inspect 
#    message = @slowlogs[:"#{tag}"].shift

    
#puts "VALIDATINGGGGGGGGGGGGGGGGGGGGGGg ..." + message

    if message.start_with?('# Time: ')
      @boolRegex0 = true
    end
    if  (message =~ REGEX1 )

     # puts "matches REGEX1" + message

       @boolRegex1 = true
    end
    if (message =~ REGEX2)
     # puts "matches REGEX2" + message

      @boolRegex2 = true
    end
    if (message =~ REGEX3)
     # puts "matches REGEX3" + message

       @boolRegex3 = true
     end
    if (message =~ REGEX4)
       #puts "matches REGEX4" + message

       @boolRegex4 = true
    end
    if (message =~ REGEX5)
     #  puts "matches REGEX5" + message
  
       @boolRegex5 = true
    end
    if (message =~ REGEX6)
     #  puts "matches REGEX6" + message
     
       @boolRegex6 = true
    end
   if message.end_with?(';') && !message.upcase.start_with?('USE ', 'SET TIMESTAMP=')
     #   puts "matches REGEX7" + message
        @boolRegex7 = true

    end
  if message.upcase.start_with?('SELECT', 'INSERT', 'DELETE', 'UPDATE', 'REPLACE', 'CREATE')
     #   puts "matches REGEX8" + message
        @boolRegex8 = true

    end

   #puts @boolRegex0 && @boolRegex1 && @boolRegex2 && @boolRegex3 && @boolRegex4 && @boolRegex6 && @boolRegex7
    return @boolRegex0 && @boolRegex1 && @boolRegex2 && @boolRegex3 && @boolRegex4  && @boolRegex6  && @boolRegex7  && @boolRegex8

 end  


  def parse_message(tag, time, server)
    record = {}
    date   = nil


#puts "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXx" +  @slowlogs.inspect

    # Skip the message that is output when after flush-logs or restart mysqld.
    # e.g.) /usr/sbin/mysqld, Version: 5.5.28-0ubuntu0.12.04.2-log ((Ubuntu)). started with:
#    begin
      message = @slowlogs[:"#{tag}"].shift
#    end while !message.start_with?('#')

#    if message.start_with?('# Time: ')
#      date    = Time.parse(message[8..-1].strip)
#      message = @slowlogs[:"#{tag}"].shift
#    end
   sql = ""

    begin
      #puts "MMMMMMMMMMMMMM " + message

     if message.start_with?('# Time: ')
      date    = Time.parse(message[8..-1].strip)
     elsif  (message =~ REGEX1 )

       #puts "matches REGEX1"
       record['user'] = $1
       record['host'] = $2
     elsif (message =~ REGEX2)
       #puts "matches REGEX2"
       record['schema']    = $1
       record['last_errno']     = $2.to_i
       record['killed']     = $3.to_i

     elsif (message =~ REGEX3)
       #puts "matches REGEX3"
       record['query_time']    = $1.to_f
       record['lock_time']     = $2.to_f
       record['rows_sent']     = $3.to_i
       record['rows_examined'] = $4.to_i
       record['rows_affected'] = $5.to_i

      elsif (message =~ REGEX4 )
       #puts "matches REGEX4"
       record['bytes_sent']    = $1.to_i
      
      elsif (message =~ REGEX5)
       record['use']    = $1

      elsif (message =~ REGEX6)

       #puts "matches REGEX6"
       record['timestamp'] = $1

      else
       #puts "matches REGEX7"

       sql = sql + " " + message
     end

     message = @slowlogs[:"#{tag}"].shift

    end while !message.nil?

    record['server'] = server 
    record['sql'] = sql
#.slice(0..100) 

    @boolRegex1 = false
    @boolRegex2 = false
    @boolRegex3 = false
    @boolRegex4 = false
    @boolRegex5 = false
    @boolRegex6 = false
    @boolRegex7 = false
    @boolRegex8 = false

  time = date.to_i if date
  
  flush_emit(tag, time, record)
  end

  def flush_emit(tag, time, record)
    @slowlogs[:"#{tag}"].clear
    _tag = tag.clone
    filter_record(_tag, time, record)
    if tag != _tag
      router.emit(_tag, time, record)
    else
      $log.warn "Can not emit message because the tag has not changed. Dropped record #{record}"
    end
  end
end
