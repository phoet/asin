ANY_ASIN = '1430218150'
ANY_SEARCH = 'Learn Objective-C'

describe ASIN do
  before(:each) do
    @helper = Object.new
    @helper.extend ASIN
    @helper.configure :logger => nil
    
    @secret = ENV['ASIN_SECRET']
    @key = ENV['ASIN_KEY']
    puts "configure #{@secret} and #{@key} for this test"
  end
  
  context "configuration" do
    it "should fail without secret and key" do
      lambda { @helper.lookup ANY_ASIN }.should raise_error(RuntimeError)
    end
    
    it "should not override the configuration" do
      config = @helper.configure :something => 'wont get overridden'
      config[:something].should_not be_nil

      config = @helper.configure :different => 'is also set'
      config[:something].should_not be_nil
      config[:different].should_not be_nil
    end
  end
  
  context "lookup and search" do
    before(:each) do
      @helper.configure :secret => @secret, :key => @key
    end
    
    it "should lookup a book" do
      item = @helper.lookup(ANY_ASIN)
      item.title.should =~ /Learn Objective/
    end

    it "should search a book with fulltext" do
      items = @helper.search(ANY_SEARCH)
      items.should have(10).things
      
      items.first.title.should =~ /Learn Objective/
    end
  end
end
