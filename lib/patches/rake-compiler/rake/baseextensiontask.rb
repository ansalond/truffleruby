Truffle::Patching.require_original __FILE__

module Rake
    class BaseExtensionTask < TaskLib
      def binary(platform = nil)
        ext = 'su'
        "#{File.basename(@name)}.#{ext}"
      end
    end
end
