require 'yaml'
require 'result'
require 'cube'
require 'letter_pair'
require 'xdg_helper'
require 'sqlite3'

class ResultsPersistence

  def initialize(db)
    @db = db
  end

  def self.create_in_memory
    db = SQLite3::Database.new(':memory:')
    ResultsPersistence.new(db)
  end

  class DBConnectionHelper
    include XDGHelper
    
    def old_results_file
      data_file('results.yml')
    end

    def db_file
      data_file('results.sqlite3')
    end
  end
    
  def self.create_for_production

    helper = DBConnectionHelper.new
    db = SQLite3::Database.new(helper.db_file.to_s)
    db.execute 'CREATE TABLE IF NOT EXISTS Results(Id INTEGER PRIMARY KEY, Mode TEXT, Timestamp INTEGER, TimeS REAL, Input TEXT, FailedAttempts INTEGER, Word TEXT)'
    
    count = db.get_first_row('SELECT count(*) FROM Results')[0]
    if count == 0 and File.exists?(helper.old_results_file)
      puts "SQLite DB Empty, filling from YAML data."
      old_results = YAML::load(File.read(old_results_file))
      old_results.each do |mode, results|
        puts "Storing #{results.length} results for #{mode}."
        results.each do |old_r|
          new_r = Result.new(mode, old_r.timestamp, old_r.time_s, old_r.input, old_r.failed_attempts, old_r.word)
          record_result(new_r)
        end
      end
    end
    ResultsPersistence.new(db)
  end

  def load_results
    stm = @db.prepare 'SELECT Mode, Timestamp, TimeS, Input, FailedAttempts, Word FROM Results'
    results = {}
    stm.execute.each do |r|
      mode = r[0].to_sym
      result = Result.from_raw_data(r)
      results[mode] ||= []
      results[mode].push(result)
    end
    results
  end

  def replace_word(mode, input, word)
    stm = @db.prepare 'UPDATE Results SET Word = ? WHERE Mode = ? and Input = ?';
    stm.execute(word, mode, input)
  end
  
  # Delete all results that happened after the given time.
  # Useful if you screwed up and want to delete results of the last 10 seconds.
  def delete_after_time(mode, time)
    stm = @db.prepare 'DELETE FROM Results WHERE Mode = ? and Timestamp > ?';
    stm.execute(mode.to_s, time.to_i)
  end

  def record_result(result)
    stm = @db.prepare ('INSERT INTO Results(Mode, Timestamp, TimeS, Input, FailedAttempts, Word) Values(?, ?, ?, ?, ?, ?)')
    stm.execute(result.to_raw_data)
  end
end
