
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
        #puts "Argument: #{arg}"
        case arg
        when "-h"
            puts "HRLLLP!"
        end
    else
        #puts "File: #{arg}"
        files.push(arg)
    end
end

# -
#   byte filesize[3]; /* Total size of original file */
#   byte segstart[3]; /* Offset into original file of start of this seg */
#   byte acmode;      /* ProDOS file access mode */
#   byte filetype;    /* ProDOS file type */
#   byte auxtype[2];  /* ProDOS auxiliary file type */
#   byte storetype;   /* ProDOS file storage type */
#   byte blksize[2];  /* Number of 512-byte blocks in original file */
#   byte credate[2];  /* File creation date, in ProDOS 8 format */
#   byte cretime[2];  /* File creation time, in ProDOS 8 format */
#   byte moddate[2];  /* File modification date */
#   byte modtime[2];  /* File modification time */
#   byte seglen[3];   /* Length in bytes of this segment */
#   byte crc[2];      /* CRC checksum of preceding fields */
#   byte filler;      /* Unused filler byte */

class BinsciiHeader
    attr_accessor :filesize, :segment_start, :access_mode, :filetype
    attr_accessor :auxtype, :storage_type, :block_size, :create_date
    attr_accessor :create_time, :modified_date, :modified_time
    attr_accessor :segment_length, :crc

    def initialize(s, ub)

        # these are all part of a struct and can not move
        @filesize = ub.apple_word(s[0..2])
        @segment_start = ub.apple_word(s[3..5])
        @access_mode = ub.apple_word(s[6])
        @filetype = ub.apple_word(s[7])
        @auxtype = ub.apple_word(s[8..9])
        @storage_type = ub.apple_word(s[10])
        @block_size = ub.apple_word(s[11..12])
        @create_date = ub.apple_word(s[13..14])
        @create_time = ub.apple_word(s[15..16])
        @modified_date = ub.apple_word(s[17..18])
        @modified_time = ub.apple_word(s[19..20])
        @segment_length = ub.apple_word(s[21..23])
        @crc = ub.apple_word(s[24..25])
    end

    def to_s
        "filesize: #{filesize} \tsegment_start: #{segment_start} \tfiletype: #{filetype} \tauxtype: #{auxtype}"
    end
end


class Unbinscii
    attr_accessor :alphabet

    def initialize(alphabet)
        @alphabet = alphabet
    end

    def decode_prodos_filename(s)
        len = alphabet.index(s[0])
        s[1..len]
    end

    def apple_word(s)
        result = 0
        
        # ruby is weird.  multi char slice is array, single char slice is int
        if s.is_a? Numeric
            result = s
        else
            multi = 1
            s.each do |c|
                result += c*multi
                multi *= 256        # "byte shifting"
            end
        end
        result
    end

    # get four chars and convert back to three byts
    def decode_string(s)
        result = []
        i = 0       #in
        o = 0       #out
        s.scan(/.{1,4}/).each do |quadchars|
            result[o] = ((alphabet.index(quadchars[3]) << 2) | (alphabet.index(quadchars[2]) >> 4)) & 0xFF
            o += 1
            result[o] = ((alphabet.index(quadchars[2]) << 4) | (alphabet.index(quadchars[1]) >> 2)) & 0xFF
            o += 1
            result[o] = ((alphabet.index(quadchars[1]) << 6) | (alphabet.index(quadchars[0]))) & 0xFF
            o += 1
        end
        result

#         *out++ = ((alphabet[in[3]] << 2) | (alphabet[in[2]] >> 4)) & 0xFF;
# *out++ = ((alphabet[in[2]] << 4) | (alphabet[in[1]] >> 2)) & 0xFF;
# *out++ = ((alphabet[in[1]] << 6) | (alphabet[in[0]]))      & 0xFF;
    end

end





header = "FiLeStArTfIlEsTaRt"
files.each do |file|
    File.open(file, "r") do |f|
    found_header = false
    found_alpha = false
    found_file_head = false
    ub = false
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
                ub = Unbinscii.new(line.chars)

            elsif !found_file_head
                puts "Grabbing file header data/metadata: #{line_num}"
                puts line
                found_file_head = true
                filename = ub.decode_prodos_filename(line)
                # filename = line[0..15]
                puts "ProDOS Filename: #{filename}"

                bh = BinsciiHeader.new(ub.decode_string(line[16..-1]), ub)
                puts bh.to_s
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

# File.readlines('foo').each do |line|
