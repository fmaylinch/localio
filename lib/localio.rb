require 'localio/version'
require 'localio/locfile'
require 'localio/processor'
require 'localio/localizable_writer'
require 'localio/filter'

module Localio

  def self.from_cmdline(args)

    puts "Localio #{Localio::VERSION}"

    if ARGV.empty?
      if File.exist? 'Locfile'
        process_locfile('Locfile')
      else
        raise ArgumentError, 'Locfile not found in current directory, and no compatible file supplied in arguments.'
      end
    else
      process_locfile(ARGV.shift)
    end
  end

  def self.from_configuration(configuration)
    @configuration = configuration
    generate_localizables
  end

  private

  def self.process_locfile(path)
    @configuration = Locfile.load(path)
    generate_localizables
  end

  def self.generate_localizables
    process_to_memory
    apply_filters
    build_localizables
  end

  def self.process_to_memory
    @localizables = Processor.load_localizables @configuration.platform_options,
                                                @configuration.source_service,
                                                @configuration.source_options
  end

  def self.apply_filters
    @localizables[:segments] = Filter.apply_filter @localizables[:segments],
                                                   @configuration.only,
                                                   @configuration.except
  end

  def self.build_localizables
    LocalizableWriter.write @configuration.platform_name,
                            @localizables[:languages],
                            @localizables[:segments],
                            @configuration.output_path,
                            @configuration.formatting,
                            :default_language => @localizables[:default_language]
    puts 'Done!'.green
  end

end
