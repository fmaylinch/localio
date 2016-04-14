class Segment

  attr_accessor :key, :translation, :language

  def initialize(key, translation, language)

    if translation == '[[IGNORE]]'
      @translation = nil
      return
    end

    @key = key
    translation = '' if translation == '[[BLANK]]'
    @translation = translation.replace_escaped
    @language = language
  end

  def is_comment?
    @key == nil
  end

  def ignore?
    @translation == nil
  end

end