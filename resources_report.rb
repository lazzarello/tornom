#!/usr/bin/ruby -w

require 'rubygems'
require 'RRD'

# price units are US dollars
instance_hourly_price = 0.085
inbound_bandwidth_price_per_gb = 0.10
# 1GB to 10000GB is the following price
outbound_bandwidth_price_per_gb = 0.15

uptime = File.read("/proc/uptime")
network_device = "wlan0"
rrd = "/var/lib/munin/localdomain/localhost.localdomain-if_#{network_device}-up-c.rrd"
start = Time.now.to_i
netstats = `cat /proc/net/dev | grep #{network_device}`.split

# optional method to use a munin RRD to calculate resource usage. Probably not
# as reliable as using the /proc filesystem
def rrdbandwidth
  # extract four variables with corresponding values from the rrd data.
  # data is some mysterious number, usually 42.
  # fstart and fend are the start and end times in unix epoc notation.
  # step is each sample point as a float inside an array in an enclosing array.
  (fstart, fend, data, step) = RRD.fetch( rrd, "--start", start.to_s, "--end",
  (start + 300 * 300).to_s, "AVERAGE")

  # filter out all the NaN values
  step = step.reject { |i| i.to_s == "NaN" }.flatten

  # sum all the values in step and put into kbytes_used
  kbytes_used = 0.0
  step.each { |i| kbytes_used += i }
  puts "#{kbytes_used} units used in #{rrd}"
end

outbound_bytes = netstats[8]
inbound_bytes = (netstats[0].split ":").last
uptime_hours = ((uptime.split(" ").first).to_f / 60 / 60).round

def calculate_outbound_cost(bytes)
  # outbound bandwidth is free if total transfered is less than 1 GB
  if (bytes.to_i < 1000000000)
    return "0.00"
  else
    return (bytes.to_f / 1000000000) * outbound_bandwidth_price_per_gb 
  end
end


instance_cost = sprintf "%.2f", (instance_hourly_price * uptime_hours)
outbound_cost = sprintf "%.2f", calculate_outbound_cost(outbound_bytes)
inbound_cost = sprintf "%.2f", ((inbound_bytes.to_f / 1000000000) * inbound_bandwidth_price_per_gb)

puts "Your instance hours cost US $#{instance_cost}"
puts "Your outbound bandwidth cost is US $#{outbound_cost}"
puts "Your inbound bandwidth cost is US $#{inbound_cost}"
