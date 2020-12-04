class ModelUtils

  # format for bps,Kbps,Mb etc...
  def self.fmt_prefix_2 raw_value
      raw_value = raw_value.to_f
      units_str = [
                    [1099511627776.0,"T","%.2f %s"],
                    [1073741824.0,   "G","%.2f %s"],
                    [1048576.0,      "M","%.2f %s"],
                    [1024.0,         "K","%.2f %s"],
                    [1,     "", "%d %s"],
                    [1e-03, "m","%.3f %s"],
                    [1e-06, "u","%.3f %s"],
                    [1e-09, "n","%.3f %s"],
                    [1e-12, "p","%.3f %s"],
                  ]

    return "0 " if raw_value == 0

    units_str.each do |unit|
          if raw_value >= unit[0]
            retval = raw_value  / unit[0]
            return format(unit[2], retval, unit[1])
          end
    end
    return raw_value.to_s
   end
 # format for bps,Kbps,Mb etc...
 def self.fmt_prefix_10 raw_value
  raw_value = raw_value.to_f
  units_str = [
                    [1e+12,"T","%.2f %s"],
                    [1e+9,   "G","%.2f %s"],
                    [1e+6,      "M","%.2f %s"],
                    [1000,         "K","%.2f %s"],
                    [1,     "", "%d %s"],
                    [1e-03, "m","%.3f %s"],
                    [1e-06, "u","%.3f %s"],
                    [1e-09, "n","%.3f %s"],
                    [1e-12, "p","%.3f %s"],
              ]

    return "0 " if raw_value == 0

    units_str.each do |unit|
      if raw_value >= unit[0]
        retval = raw_value  / unit[0]
        return format(unit[2], retval, unit[1])
      end
    end
    return raw_value.to_s
  end
  # Formats a bandwidth : So a number like 11899833 = 11.90 M
  def self.fmt_volume(val,units="")
    fmt_prefix_2(val)+ units.to_s.gsub(/ps$/,"")
  end

  def self.fmt_bw(val,units="bps")
    fmt_prefix_10(val) + units.to_s.downcase
  end
  def self.fmt_ts(tvsec,opts={})
    if opts[:show_time]==false
      return Time.at(tvsec.to_i).strftime("%F")
    else
      return Time.at(tvsec.to_i).strftime("%F %T")
    end
   end
  # Print a time interval in terms of D/H/M/S
  def self.fmt_time_interval(dsecs)
   dsecs = dsecs.to_i


   return "0" if dsecs < 1
   divs = [ [24*3600, "d"],
            [3600,    "h" ],
            [60,      "m"],
            [1,       "s"]
          ]
   outs = divs.inject("") do |mem,ai|
     val = dsecs / ai[0]
     dsecs = dsecs % ai[0]
     val<1?mem: mem + "#{val.to_i} #{ai[1]} "
   end
   return outs.chop
  end

  
  # Convert a DB Timestamp (a 64 bit Secs + USecs) into a Ruby Time object
  def self.FromDBTime db_timestamp
      Time.at(db_timestamp.to_i>>32)
  end
end
