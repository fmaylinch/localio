require 'localio/string_helper'

module Formatter
  def self.format(key, formatter, callback)
    case formatter
      when :smart
        # Smart formatting is given by the processor.
        # I don't like this very much but creating more classes seemed overkill.
        callback.call(key)
      when :none
        key
      when :camel_case
        key.space_to_underscore.strip_tag.camel_case
      when :snake_case
        key.space_to_underscore.strip_tag.downcase
      else
        raise ArgumentError, 'Unknown formatting used. Must use :smart, :none, :camel_case or :snake_case'
    end
  end

  def self.check_lang_term(lang, term)
    raise "Missing message for key '#{term.keyword}' in language '#{lang}'" if term.values[lang].to_s.strip.length == 0
  end
end