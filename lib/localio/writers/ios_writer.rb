require 'localio/template_handler'
require 'localio/segments_list_holder'
require 'localio/segment'
require 'localio/formatter'

class IosWriter
  def self.write(languages, terms, path, formatter, options)
    puts 'Writing iOS translations...'

    constant_segments = nil
    languages.keys.each do |lang|
      output_path = File.join(path, "#{lang}.lproj/")

      # We have now to iterate all the terms for the current language, extract them, and store them into a new array

      segments = SegmentsListHolder.new lang
      constant_segments = SegmentsListHolder.new lang
      terms.each do |term|
        Formatter.check_lang_term(lang, term)
        key = Formatter.format(term.keyword, formatter, method(:ios_key_formatter))
        translation = ios_parsing term.values[lang]
        replace_placeholders translation
        segment = Segment.new(key, translation, lang)
        segment.key = nil if term.is_comment?
        segments.segments << segment

        unless term.is_comment?
          constant_key = ios_constant_formatter term.keyword
          constant_value = key
          constant_segment = Segment.new(constant_key, constant_value, lang)
          constant_segments.segments << constant_segment
        end
      end

      TemplateHandler.process_template 'ios_localizable.erb', output_path, 'Localizable.strings', segments
      puts " > #{lang.yellow}"
    end

# TODO: add an option to enable/disable this
#    unless constant_segments.nil?
#      TemplateHandler.process_template 'ios_constant_localizable.erb', path, 'LocalizableConstants.h', constant_segments
#      puts ' > ' + 'LocalizableConstants.h'.yellow
#    end
  end

  private

  def self.ios_key_formatter(key)
    '_'+key.space_to_underscore.strip_tag.capitalize
  end

  def self.ios_constant_formatter(key)
    'kLocale'+key.space_to_underscore.strip_tag.camel_case
  end

  def self.ios_parsing(term)
    term.gsub('"', '\\"')
  end

  # Replaces each '{placeholder}' by '%@'
  def self.replace_placeholders(term)
    term.gsub!(/{[^}]+}/,'%@')
  end

end
