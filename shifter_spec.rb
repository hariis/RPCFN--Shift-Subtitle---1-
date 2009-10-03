require 'shifter'
  describe Shifter do
      it "should shift ahead by the given time" do
        shifter = Shifter.new
        options = {}
        options[:operation] = 'add'
        options[:secs] = 1
        options[:msecs] = 1
        shifter.options = options
        result_start,result_end= shifter.shift_times("00:00:20,000","00:00:18,999")
        result_start.should == "00:00:21,001"
        result_end.should == "00:00:20,000"
      end
      
      it "should shift back by the given time" do
        shifter = Shifter.new
        options = {}
        options[:operation] = 'sub'
        options[:secs] = 1
        options[:msecs] = 1
        shifter.options = options
        result_start,result_end= shifter.shift_times("00:00:21,001","00:00:20,000")
        result_start.should == "00:00:20,000"
        result_end.should == "00:00:18,999"
      end
  end

