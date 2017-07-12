module Yuba
  class ViewModel
    class << self
      def success(**args)
        new(args.merge(success: true))
      end
    end

    def initialize(success: true, **args)
      @success = success
      args.each { |k,v| self.class.send(:define_method, k) { v } }
    end

    def success?
      @success
    end

    def failure?
      !@success
    end

    def to_model
      form
    end
  end
end
