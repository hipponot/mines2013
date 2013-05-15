#!/usr/bin/env ruby
require "thor"
require "ptools"

class FileOperations < Thor

  desc "rename", "Rename a collection of files"
  method_option :fileset, :aliases => "-f", :required=>true, :desc => "Filset string"
  method_option :match, :aliases => "-m", :required=>true, :desc => "Match regex"
  method_option :replace, :aliases => "-r", :required=>true, :desc => "Replace string"
  def rename
    # Handle directories
    Dir.glob(options[:fileset]).select {|f| File.directory? f }.select { |f| f =~ /#{options[:match]}/ }.each do |f|
      nf = f.gsub(/#{options[:match]}/, options[:replace])
      FileUtils.cp_r(f,nf)
      FileUtils.rm_r(f)
    end
    # Handle files
    Dir.glob(options[:fileset]).select {|f| File.file? f }.select { |f| f =~ /#{options[:match]}/ }.each do |f|
      nf = f.gsub(/#{options[:match]}/, options[:replace])
      FileUtils.mv(f,nf)
    end
  end

  desc "replace", "Replace a string in a collection of files"
  method_option :fileset, :aliases => "-f", :required=>true, :desc => "Filset string"
  method_option :match, :aliases => "-m", :required=>true, :desc => "Match regex"
  method_option :replace, :aliases => "-r", :required=>true, :desc => "Replace string"
  def replace
    Dir.glob(options[:fileset]).select {|f| File.file? f }.each do |f| 
      next if File.binary?(f)
      text = File.read(f).gsub(/#{options[:match]}/, options[:replace])
      File.open(f, "w") { |f| f.puts text }
    end
  end

end

FileOperations.start

