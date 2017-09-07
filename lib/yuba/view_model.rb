module Yuba
  class ViewModel
    class << self
      def success(**args)
        new(args.merge(success: true))
      end

      def failure(**args)
        new(args.merge(success: false))
      end
    end

    def initialize(success: true, **args)
      @success = success
      args.each { |k,v| self.singleton_class.send(:define_method, k) { v } }
    end

    def success?
      @success
    end

    def failure?
      !@success
    end
  end
end
