class MarkdownWriter
  def initialize(date)
    @filename = "#{date.strftime('%Y%m%d')}.md"
  end

  def write(messages)
    File.open(@filename, 'w') do |file|
      file.puts "# #{@filename.gsub('.md', '')}"
      file.puts
      messages.each do |message|
        file.puts message
      end
    end
  end
end
