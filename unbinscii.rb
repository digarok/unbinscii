
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
    found_header = false
    found_alpha = false
    found_file_head = false
    line_num = 0
        f.each_line do |line|
            line.strip!
            if !found_header
                puts "Scanning for header: #{line_num}"
                if line =~ /#{header}/i
                    found_header = true
                    puts "Header start: #{line_num}"
                end
            elsif !found_alpha
                puts "Grabbing encoding alphabet: #{line_num}"
                puts "     \"#{line}\" "
                found_alpha = true
                encoding_chars = line.chars
            elsif !found_file_head
                puts "Grabbing file header data/metadata: #{line_num}"
                found_file_head = true
                filename = line[0..15]
                puts "ProDOS Filename: #{filename}"
            end
            line_num += 1
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
