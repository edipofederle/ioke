include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

import Java::java.io.StringReader unless defined?(StringReader)

def parse(str)
  ioke = IokeRuntime.get_runtime()
  ioke.parse_stream(StringReader.new(str))
end

describe "parsing" do 
  describe "terminators" do 
    it "should parse a newline as a terminator" do 
      m = parse("\n").to_string
      m.should == ";\n"
    end

    it "should parse two newlines as one terminator" do 
      m = parse("\n\n").to_string
      m.should == ";\n"
    end

    it "should parse a semicolon as a terminator" do 
      m = parse(";").to_string
      m.should == ";\n"
    end

    it "should parse two semicolons as one terminator" do 
      m = parse(";;").to_string
      m.should == ";\n"
    end

    it "should parse one semicolon and one newline as one terminator" do 
      m = parse(";\n").to_string
      m.should == ";\n"
    end

    it "should parse one newline and one semicolon as one terminator" do 
      m = parse("\n;").to_string
      m.should == ";\n"
    end

    it "should parse one newline and one semicolon and one newline as one terminator" do 
      m = parse("\n;\n").to_string
      m.should == ";\n"
    end
  end

  describe "parens without preceeding message" do 
    it "should be translated into identity message" do 
      m = parse("(1)").to_string
      m.should == "(1)"
    end
  end
  
  describe "square brackets" do 
    it "should be parsed correctly in regular message passing syntax" do 
      m = parse("[]()").to_string
      m.should == "[]"
    end

    it "should be parsed correctly in regular message passing syntax with arguments" do 
      m = parse("[](123)").to_string
      m.should == "[](123)"
    end

    it "should be parsed correctly in regular message passing syntax with arguments and receiver" do 
      m = parse("foo bar(1) [](123)").to_string
      m.should == "foo bar(1) [](123)"
    end
    
    it "should be parsed correctly when empty" do 
      m = parse("[]").to_string
      m.should == "[]"
    end

    it "should be parsed correctly with argument" do 
      m = parse("[1]").to_string
      m.should == "[](1)"
    end

    it "should be parsed correctly with arguments" do 
      m = parse("[1, 2]").to_string
      m.should == "[](1, 2)"
    end

    it "should be parsed correctly with terminators inside" do 
      m = parse("[1, \nfoo(24)]").to_string
      m.should == "[](1, foo(24))"
    end

    it "should be parsed correctly directly after an identifier" do 
      m = parse("foo[1, 2]").to_string
      m.should == "foo [](1, 2)"
    end

    it "should be parsed correctly with a space directly after an identifier" do 
      m = parse("foo [1, 2]").to_string
      m.should == "foo [](1, 2)"
    end

    it "should be parsed correctly inside a function application" do 
      m = parse("foo([1, 2])").to_string
      m.should == "foo([](1, 2))"
    end

    it "should not parse correctly when mismatched" do 
      proc do 
        parse("foo([1, 2)]")
      end.should raise_error
    end

    it "should not parse correctly when missing end" do 
      proc do 
        parse("[1, 2")
      end.should raise_error
    end
  end
  
  describe "curly brackets" do 
    it "should be parsed correctly in regular message passing syntax" do 
      m = parse("{}()").to_string
      m.should == "{}"
    end

    it "should be parsed correctly in regular message passing syntax with arguments" do 
      m = parse("{}(123)").to_string
      m.should == "{}(123)"
    end

    it "should be parsed correctly in regular message passing syntax with arguments and receiver" do 
      m = parse("foo bar(1) {}(123)").to_string
      m.should == "foo bar(1) {}(123)"
    end
    
    it "should be parsed correctly when empty" do 
      m = parse("{}").to_string
      m.should == "{}"
    end

    it "should be parsed correctly with argument" do 
      m = parse("{1}").to_string
      m.should == "{}(1)"
    end

    it "should be parsed correctly with arguments" do 
      m = parse("{1, 2}").to_string
      m.should == "{}(1, 2)"
    end

    it "should be parsed correctly with terminators inside" do 
      m = parse("{1, \nfoo(24)}").to_string
      m.should == "{}(1, foo(24))"
    end

    it "should be parsed correctly directly after an identifier" do 
      m = parse("foo{1, 2}").to_string
      m.should == "foo {}(1, 2)"
    end

    it "should be parsed correctly with a space directly after an identifier" do 
      m = parse("foo {1, 2}").to_string
      m.should == "foo {}(1, 2)"
    end

    it "should be parsed correctly inside a function application" do 
      m = parse("foo({1, 2})").to_string
      m.should == "foo({}(1, 2))"
    end

    it "should not parse correctly when mismatched" do 
      proc do 
        parse("foo({1, 2)}")
      end.should raise_error
    end

    it "should not parse correctly when missing end" do 
      proc do 
        parse("{1, 2")
      end.should raise_error
    end
  end

  describe "identifiers" do 
    it "should be allowed to begin with colon" do 
      m = parse(":foo").to_string
      m.should == ":foo"
    end

    it "should be allowed to only be a colon" do 
      m = parse(":").to_string
      m.should == ":"
    end

    it "should be allowed to end with colon" do 
      m = parse("foo:").to_string
      m.should == "foo:"
    end

    it "should be allowed to have a colon in the middle" do 
      m = parse("foo:bar").to_string
      m.should == "foo:bar"
    end

    it "should be allowed to have more than one colon in the middle" do 
      m = parse("foo::bar").to_string
      m.should == "foo::bar"

      m = parse("f:o:o:b:a:r").to_string
      m.should == "f:o:o:b:a:r"
    end
  end
end
