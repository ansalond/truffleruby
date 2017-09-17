Truffle::Patching.require_original __FILE__

module Rake
  class ExtensionTask < BaseExtensionTask
    def init(name = nil, gem_spec = nil)
      super
      @config_script = 'extconf.rb'
      @source_pattern = "*.{c,cc,cpp}"
      @compiled_pattern = "*.{bc,su}"
      @cross_compile = false
      @cross_config_options = []
      @cross_compiling = nil
      @no_native = false
      @config_includes = []
      @ruby_versions_per_platform = {}
    end
  end
end
