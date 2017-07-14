describe "Squealer" do
  let(:squeal) { Squealer.new }

  describe "#is_blank?" do
    it "returns true if item is a blank string" do
      item = ''
      expect(squeal.is_blank?(item)).to eq(true)
    end

    it "returns false if item is not a blank string" do
      item = 'hello!'
      expect(squeal.is_blank?(item)).to eq(false)
    end
  end

  describe "#is_bool?" do
    it "returns true if item is true" do
      item = "true"
      expect(squeal.is_bool?(item)).to eq(true)
    end

    it "returns true if item is false" do
      item = "false"
      expect(squeal.is_bool?(item)).to eq(true)
    end

    it "returns false if item is neither true or false" do
      item = 'not_true_or_false'
      expect(squeal.is_blank?(item)).to eq(false)
    end
  end

  describe "#is_int?" do
    it "returns true if item is an int" do
      item = "249500"
      expect(squeal.is_int?(item)).to eq(true)
    end

    it "returns false if item has a decimal" do
      item = "304.23885"
      expect(squeal.is_int?(item)).to eq(false)
    end

    it "returns false if item contains alphabetic characters" do
      item = "13million"
      expect(squeal.is_blank?(item)).to eq(false)
    end
  end

  describe "#is_float?" do
    it "returns true if item is a float" do
      item = "249.500"
      expect(squeal.is_float?(item)).to eq(true)
    end

    it "returns false if item doesn't have a decimal" do
      item = "30423885"
      expect(squeal.is_float?(item)).to eq(false)
    end

    it "returns false if item contains alphabetic characters" do
      item = "13million"
      expect(squeal.is_float?(item)).to eq(false)
    end
  end

  describe "#is_timestamp?" do
    it "returns true if item is a timestamp in iso8601 format" do
      item = "2007-11-19T08:37:48-0600"
      expect(squeal.is_timestamp?(item)).to eq(true)
    end

    it "returns false if item s a timestamp not in iso8601 format" do
      item = "07nov19"
      expect(squeal.is_timestamp?(item)).to eq(false)
    end
  end

  describe "#is_header?" do
    it "returns true if line_index is 0" do
      line_index = 0
      expect(squeal.is_header?(line_index)).to eq(true)
    end

    it "returns false if line_index is not 0" do
      line_index = 1
      expect(squeal.is_header?(line_index)).to eq(false)
    end
  end

  describe "#table_name #table_name=" do
    it "sets and gets table_name" do
      squeal.table_name = "data_stuff"
      expect(squeal.table_name).to eq("data_stuff")
    end

    it "doesn't set table name if name starts with a number" do
      squeal.table_name = "2data"
      expect(squeal.table_name).to eq(nil)
    end

    it "doesn't set table name if name has something other than alphanumeric characters" do
      squeal.table_name = "da.ta"
      expect(squeal.table_name).to eq(nil)
    end
  end

  describe "#csv= #csv" do
    it "sets and gets csv" do
      new_file = File.open(File.join(File.dirname(__FILE__), "../data.csv"))
      squeal.csv = new_file
      expect(squeal.csv.class).to eq(File)
    end

    it "only sets csv when input is File class" do
      new_file = 'hi'
      squeal.csv = new_file
      expect(squeal.csv).to eq(nil)
    end
  end

  describe "#init_headers" do
    it "returns a hash" do
      new_file = File.open(File.join(File.dirname(__FILE__), "../data.csv"))
      squeal.csv = new_file
      expect(squeal.init_headers("id,place,score").class).to eq(Hash)
    end

    it "returns a hash with correct headers and data types" do
      new_file = File.open(File.join(File.dirname(__FILE__), "../data.csv"))
      squeal.csv = new_file
      expect(squeal.init_headers("id,place,score")).to include(
        0 => {:name=>"id"},
        1 => {:name=>"place"},
        2 => {:name=>"score"}
      )
    end
  end

  describe "#build_header_hash" do
    it "returns a hash" do
      new_file = File.open(File.join(File.dirname(__FILE__), "../data.csv"))
      squeal.csv = new_file
      expect(squeal.build_header_hash.class).to eq(Hash)
    end

    it "returns a hash with correct headers and data types" do
      new_file = File.open(File.join(File.dirname(__FILE__), "../data.csv"))
      squeal.csv = new_file
      expect(squeal.build_header_hash).to include(
        0 => {:name=>"id", :type=>"int", :length=>1},
        1 => {:name=>"place", :type=>"varchar", :length=>5},
        2 => {:name=>"score", :type=>"float4", :length=>4}
      )
    end
  end

  describe "#is_type_consistant?" do
    it "returns true if types are the same" do
      type_in_hash = 'int'
      current_type = 'int'
      expect(squeal.is_type_consistant?(type_in_hash, current_type)).to eq(true)
    end

    it "returns false if types are the same" do
      type_in_hash = 'float4'
      current_type = 'int'
      expect(squeal.is_type_consistant?(type_in_hash, current_type)).to eq(false)
    end

  end

  describe "#print_postgres_query" do
    it "returns a postgresql query string" do
      new_file = File.open(File.join(File.dirname(__FILE__), "../data.csv"))
      squeal.csv = new_file
      squeal.table_name = "data"
      expect(squeal.print_postgres_query).to eq("CREATE TABLE data (id int, place varchar(5), score float4);")
    end

    it "returns error message if incorrect input" do
      new_file = File.open(File.join(File.dirname(__FILE__), "../data.csv"))
      expect(squeal.print_postgres_query).to eq("Error: csv and table need to be set first")
    end
  end
end
