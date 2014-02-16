require 'readline'
require 'find'

$home = ENV['HOME']
$downloads_dir = "#{$home}/Downloads"

def parse
  # Any cue files?
  cue_files = []
  Find.find(Dir.pwd) do |path|
    cue_files << path if path =~ /.*\.cue$/
  end

  puts "#{cue_files.length} cue file(s) detected." if cue_files.length > 0

  cue_files.each do |cuefile|
    cuefile_dir, = dir_of_file(cuefile, "cue")
    # flac_files = Dir["#{cuefile_dir}/**/*.flac"]
    flac_files = Find.find(cuefile_dir)

    puts flac_files
  end

  # cue_files.each {|file| p file }
end

def dir_of_file(file, extension)
  index = file.index(/\/[^\/]+\.#{extension}$/)
  [file[0..index-1], file[index..-1]]
end

Dir.chdir($downloads_dir) do
  # All the directories, excluding ., .., and those starting with $
  folders = Dir.entries(".").select {|f| (File.directory?(f) && f !~ /^\.+/ && f !~ /^\$/) }
  comp = proc {|s| folders.grep(/^#{Regexp.escape(s)}/i) }
  Readline.completion_proc = comp

  p "Please enter the project to browse (press Tab to see options): "
  while line = Readline.readline('~> ', true)
    line.strip!

    if folders.include? line
      Dir.chdir(line) { parse }
    elsif line =~ /\w*(quit|exit|fuckoff)\w*/
      abort
    else
      puts "Access denied !"
    end
  end
end

#       Dir.chdir(line) do
#         #1. Get the two file
#         cuefile = Dir["*.cue"].first
#         flacfile = Dir["*.flac"].first

#         #2. Pass them as argument to xld and output the progression bar
#         xldcommand = "xld -c \"#{cuefile}\" -f alac \"#{flacfile}\""
#         IO.popen(xldcommand) {|pipe| puts pipe.gets }

#         #3. Embed 'front.jpg' or 'front.png' into the new m4a files.
#         front_img = Dir["front.*"].first
#         imgcommand = "mp4art --add #{front_img} *.m4a"
#         IO.popen(imgcommand) {|pipe| puts pipe.gets }

#         #4. Make the booklet
#         [ "front.jpg", "back.jpg", "cd.jpg" ].each {|file| `cp #{file} ./booklet` }
#         Dir.chdir("./booklet") do
#           Dir["*.jpg"].each do |filename|
#             pdf_filename = filename.gsub(/\.jpg$/, '.pdf')
#             `convert #{filename} #{pdf_filename}`
#           end

#           booklet_pages = [ "front.pdf" ]
#           booklet_pages << Dir['*.pdf'].select {|file| file =~ /^[0-9]+.pdf/ }.sort
#           booklet_pages << ["back.pdf", "cd.pdf"]

#           `pdftk #{booklet_pages.join(" ")} output Livret.pdf`
#           `mv Livret.pdf ../`
#           `rm *.pdf`
#         end
#       end
#     end
#   end
# end