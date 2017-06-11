require 'optparse'

## Usage: unbinscii [-hs] [-o<outputfile>] <infiles>                   ##
##                                                                     ##
##           -h help                                                   ##
##           -o write to filename instead of the one in binscii file   ##
##              (only use when output only contains a single file)     ##
##              contain only one output file.                          ##
##           -s output to standard output instead of a file            ##

input_array = ARGV
puts input_array.to_s
files = []
ARGV.each do |arg|
    if arg[0] == "-"
        puts "Argument: #{arg}"
        case arg
        when "-h"
            puts "HRLLLP!"
        end
    else 
        puts "File: #{arg}"
        files.push(arg)
    end
end



header = "FiLeStArTfIlEsTaRt"
files.each do |file|
    File.open(file, "r") do |f|
        f.each_line do |line|
            if line =~ /#{header}/i
                puts line
            end
        end
    end
end


# file testing
#File.open("binscii.txt", "r") do |f|
#    f.each_line do |line|
#        puts line
#    end
#end

class Unbinscii
    def initialize(multipart_payload)
        @multipart_payload = multipart_payload
    end
end

# File.readlines('foo').each do |line|

