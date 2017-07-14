require "Date"

class Squealer
  attr_reader :table_name, :csv

  def table_name=(name)
    if /^[a-zA-Z]\w*$/.match(name)
      @table_name = name
    else
      puts "please specify a name that starts with a letter"
      puts "and only contains alphanumeric or underscore characters"
    end
  end

  def csv=(csv)
    if csv.class == File
      @csv = csv
    else
      puts "csv must be a File"
    end
  end

  def build_header_hash
    if !!@csv
      header_hash = {}
      # varchar_index_array = []
      @csv.each_with_index do |line, line_index|
        if is_header?(line_index)
          header_hash = init_headers(line)
        else
          line.strip.split(',').each_with_index do |item, item_index|
            if is_blank?(item)
              next
            elsif header_hash[item_index][:type] != "varchar"
              current_type = ""
              if is_bool?(item)
                current_type = "boolean"
              elsif is_int?(item)
                current_type = "int"
              elsif is_float?(item)
                current_type = "float4"
              elsif is_timestamp?(item)
                current_type = "timestamp"
              else
                current_type = "varchar"
              end

              if header_hash[item_index][:type]
                type_in_hash = header_hash[item_index][:type]
                if !is_type_consistant?(type_in_hash, current_type)
                  header_hash[item_index][:type] = "varchar"
                end
              else
                header_hash[item_index][:type] = current_type
              end
            end

            if !header_hash[item_index][:length]
              header_hash[item_index][:length] = item.length
            elsif header_hash[item_index][:length] < item.length
              header_hash[item_index][:length] = item.length
            end
          end
        end
      end
      header_hash
    else
      puts "Error: csv has to be set to get hash"
    end
  end

  def is_type_consistant?(type_in_hash, current_type)
    type_in_hash == current_type
  end

  def is_header?(line_index)
    line_index == 0
  end

  def init_headers(line)
    header_hash = {}
    line.strip.split(',').each_with_index{|header, header_index|
      header_hash[header_index] = {name: header}
    }
    header_hash
  end

  def is_blank?(item)
    item == ''
  end

  def is_bool?(item)
    item == "false" || item == "true"
  end

  def is_int?(item)
    !!/^\d+$/.match(item)
  end

  def is_float?(item)
    !!/^\d+\.\d+$/.match(item)
  end

  def is_timestamp?(item)
    iso8601_check = false
    begin
      if Date.iso8601(item)
        iso8601_check = true
      end
    rescue
    end
    iso8601_check
  end

  def print_postgres_query
    if !!@csv && !!@table_name
      header_hash = build_header_hash
      columns = header_hash.keys.sort.map do |column_index|
        column = header_hash[column_index]
        column_string = "#{column[:name]} #{column[:type]}"
        if column[:type] == 'varchar'
          column_string += "(#{column[:length]})"
        end
        column_string
      end
      "CREATE TABLE #{table_name} (#{columns.join(", ")});"
    else
      "Error: csv and table need to be set first"
    end
  end
end
