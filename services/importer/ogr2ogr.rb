# encoding: utf-8
require 'open3'

module CartoDB
  module Importer
    class Ogr2ogr
      ENCODING = 'UTF-8'

      def initialize(filepath, pg_options, table_name)
        self.filepath   = filepath
        self.pg_options = pg_options
        self.table_name = table_name
      end #initialize

      def command
        "#{encoding_option} #{executable_path} " +
        "-lco FID=cartodb_id " +
        "#{output_format_option} #{postgres_options} " +
        "#{filepath} #{layer_name_option}"
      end #command

      def executable_path
        `which ogr2ogr`.strip
      end #executable_path

      def run(*args)
        stdout, stderr, status  = Open3.capture3(command)
        self.command_output     = stdout + stderr
        self.exit_code          = status.to_i
        self
      end #run

      attr_reader   :exit_code, :command_output, :table_name

      private

      attr_writer   :exit_code, :command_output, :table_name
      attr_accessor :filepath, :pg_options

      def output_format_option
        "-f PostgreSQL"
      end #output_format_option

      def encoding_option
       "PGCLIENTENCODING=#{ENCODING}"
      end #encoding_option

      def layer_name_option
        "-nln #{table_name}"
      end #layer_name_option

      def postgres_options
        %Q{PG:"host=#{pg_options.fetch(:host)} }    +
        %Q{port=#{pg_options.fetch(:port)} }        +
        %Q{user=#{pg_options.fetch(:user)} }    +
        %Q{dbname=#{pg_options.fetch(:database)}" }
      end #postgres_options
    end # Ogr2ogr
  end # Importer
end # CartoDB
