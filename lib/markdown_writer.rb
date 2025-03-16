class MarkdownWriter
  def initialize(date, output_dir = '.')
    @output_dir = output_dir
    @filename = "#{date.strftime('%Y%m%d')}.md"
  end

  def write(messages)
    FileUtils.mkdir_p(@output_dir)
    filepath = File.join(@output_dir, @filename)
    
    File.open(filepath, 'w') do |file|
      file.puts "# #{@filename.gsub('.md', '')}"
      file.puts
      messages.each do |message|
        file.puts message
      end
    end
    
    filepath
  end
end
