module Yuba
  class ViewModel
    def initialize(**args)
      args.each { |k,v| self.singleton_class.send(:define_method, k) { v } }
    end
  end
end
