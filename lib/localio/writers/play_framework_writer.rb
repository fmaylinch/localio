require 'localio/template_handler'
require 'localio/segments_list_holder'
require 'localio/segment'
require 'localio/formatter'

class PlayFrameworkWriter
  def self.write(languages, terms, path, formatter, options)
    puts 'Writing Play Framework translations...'
    default_language = options[:default_language]

    languages.keys.each do |lang|

      begin
        output_path = path

        # We have now to iterate all the terms for the current language, extract them, and store them into a new array

        segments = SegmentsListHolder.new lang
        terms.each do |term|
          Formatter.check_lang_term(lang, term)
          key = Formatter.format(term.keyword, formatter, method(:play_framework_key_formatter))
          translation = play_framework_parsing term.values[lang]
          segment = Segment.new(key, translation, lang)
          next if segment.ignore?
          segment.key = nil if term.is_comment?
          segments.segments << segment
        end

        output_file = default_language == lang ? 'messages' : "messages.#{lang}"

        TemplateHandler.process_template 'java_properties_localizable.erb', output_path, output_file, segments
        puts " > #{lang.yellow}"

      rescue MissingMessage => e
        puts " > #{lang.red} ignored: #{e.message}"
      end

    end
  end

  private

  def self.play_framework_key_formatter(key)
    key.space_to_underscore.strip_tag.downcase
  end

  def self.play_framework_parsing(term)
    term.gsub("'", "''")
  end

end