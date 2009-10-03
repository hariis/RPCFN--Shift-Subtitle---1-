require 'optparse'
class Shifter
  attr_accessor :options,:iofiles
  
  def get_parameters
  
      begin
        options = {}
        optparse = OptionParser.new do|opts|
        opts.banner = "Usage: shift_subtitle.rb [options] [input_file] [output_file] "

        opts.separator ""
        opts.separator "Specific Options:"

        options[:operation] = 'none'
        
        opts.on( '--operation OPT', [:add, :sub], "Shifts ahead or back by given time" ) do |op|      
            options[:operation] = op
         end
        
         options[:time] = false
         opts.on( '--time secs,msecs', Array, "time in [secs,milliseconds] to shift" ) do |t|
              if t.length == 2
                options[:time] = true
                options[:secs] = t[0].to_i
                options[:msecs] = t[1].to_i
              end      
          end
        end
       
        #Validate the parameters we got
        if ARGV.length == 0  
          puts optparse
          exit
        end
         optparse.parse! #strips out the parameters leaving the arguments
          if  options[:time] != :true && options[:operation] != :none  && ARGV.length == 2
              #Check the out file
              out_file = File.new(ARGV[1], "r+")
              if !out_file      
                 puts "Unable to open output file!"
              end
              #Check the in files
              in_file = File.new(ARGV[0], "r")
              if !in_file      
                 puts "Unable to open input file!"
               end
          else
              puts "fatal error: Invalid Arguments" 
              puts
              puts "Check Operation" if !(options[:operation] != :none)
              puts "Check Time to Shift" if !(options[:time] != :true)
              puts "Check I/O file arguments" if !(ARGV.length == 2)
              
              puts
              puts optparse
              exit
          end
      rescue 
            puts "fatal error: Invalid Arguments" 
            puts
            $stderr.puts $!
            
            puts        
            puts optparse
            exit
      end
       @options, @iofiles = options,ARGV
  end

  def shift(the_time,shift_by)
    the_time = the_time.strip
    hr_min = the_time.split(':')[0] + ":" + the_time.split(':')[1] + ":"
    secs_msecs = the_time.split(':')[2]
    secs_msecs_together = secs_msecs.sub(/,/, '')
    
    shifted_time = secs_msecs_together.to_i + shift_by.to_i if @options[:operation].to_sym  == :add
    shifted_time = secs_msecs_together.to_i - shift_by.to_i if @options[:operation].to_sym   == :sub
    shifted_secs = shifted_time / 1000
    shifted_msecs = shifted_time % 1000 
    
    shifted_time_together = hr_min + ("%02d" % shifted_secs).concat(",#{"%03d" % shifted_msecs}")
  end

  def shift_times(start_time,end_time)
      #Get the time to shift
      shift_by = ("%02d" % @options[:secs]).to_s + ("%03d" % @options[:msecs]).to_s
      
      shifted_start_time= shift(start_time, shift_by)
      shifted_end_time= shift(end_time, shift_by)
      
      return shifted_start_time,shifted_end_time
  end

  def shift_contents
        puts "Shift starting."  
         out_file = File.new(@iofiles[1], "r+")
         print "Shifting contents"
         IO.foreach(@iofiles[0]) do |block| 
              
            out_file.syswrite(block) && next unless block.include?('-->')
              
            start_time = block.split('-->')[0]
            end_time = block.split('-->')[1]
            shifted_start_time, shifted_end_time = shift_times(start_time,end_time)
            
            out_file.syswrite(shifted_start_time + " --> " + shifted_end_time + "\n") 
            print '.'
        end
        puts "\nShift complete."   
  end


 end

