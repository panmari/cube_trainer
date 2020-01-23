require 'cube_trainer/xdg_helper'
require 'cube_trainer/array_helper'
require 'sqlite3'

module CubeTrainer

  class Cache

    include XDGHelper
    include ArrayHelper

    CACHE_DB_FILE = 'cache.sqlite3'

    def initialize(namespace)
      raise ArgumentError unless namespace =~ /^\w+$/
      @namespace = namespace
      ensure_cache_directory_exists
      @namespace
      @db = SQLite3::Database.new(cache_file(CACHE_DB_FILE).to_s)
      @db.execute('CREATE TABLE IF NOT EXISTS Cache(Namespace TEXT, Key TEXT, Value BLOB)')
      @db.execute('CREATE INDEX IF NOT EXISTS NamespaceKeyIndex ON Cache(Namespace, Key)');
    end

    def [](key)
      raise TypeError unless key.is_a?(String)
      @get_stm ||= @db.prepare('SELECT Value FROM Cache WHERE Namespace = ? AND Key = ?')
      results = @get_stm.execute(@namespace, key).to_a
      case results.length
      when 0 then nil
      when 1 then only(only(results))
      else
        raise "Got unexpected results from database."
      end
    end

    def []=(key, value)
      raise TypeError unless key.is_a?(String)
      @put_stm ||= @db.prepare('INSERT INTO Cache(Namespace, Key, Value) VALUES (?, ?, ?)')
      @put_stm.execute(@namespace, key, value)
    end
    
  end
  
end