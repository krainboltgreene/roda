require File.expand_path("helper", File.dirname(__FILE__))

describe "plugins" do
  it "should be able to override class, instance, response, and request methods, and execute configure method" do
    c = Module.new do
      self::ClassMethods = Module.new do
        def fix(str)
          opts[:prefix] + str.strip
        end
      end
      self::InstanceMethods = Module.new do
        def fix(str)
          self.class.fix(str)
        end
      end
      self::RequestMethods = Module.new do
        def hello(&block)
          on 'hello', &block
        end
      end
      self::ResponseMethods = Module.new do
        def foobar
          "Default   "
        end
      end

      def self.configure(mod, prefix)
        mod.opts[:prefix] = prefix
      end
    end

    app(:bare) do
      plugin c, "Foo "

      route do |r|
        r.hello do
          fix(response.foobar)
        end
      end
    end

    body('/hello').should == 'Foo Default'
  end
end
