baseruby="ruby --disable=gems"
ruby="${RUBY-$baseruby}"
"eval" "{" \
"`expr \"$ruby\" : echo > /dev/null || echo exec`" \
"$ruby" '-r"`expr \"$0\" : / > /dev/null || pwd`/${0#/}" "$@";' \
"}" || "exit" "$?"
ruby=ruby
class Object
  remove_const :CROSS_COMPILING if defined?(CROSS_COMPILING)
  CROSS_COMPILING = RUBY_PLATFORM
  remove_const :RUBY_PLATFORM
  remove_const :RUBY_VERSION
  remove_const :RUBY_DESCRIPTION if defined?(RUBY_DESCRIPTION)
  RUBY_PLATFORM = "x86_64-linux"
  RUBY_VERSION = "2.0.0"
  RUBY_DESCRIPTION = "ruby #{RUBY_VERSION} (2014-02-24) [#{RUBY_PLATFORM}]"
end
if RUBY_PLATFORM =~ /mswin|bccwin|mingw/
  class File
    remove_const :ALT_SEPARATOR
    ALT_SEPARATOR = "\\"
  end
end

builddir = File.expand_path(File.dirname(__FILE__))
$:.unshift(builddir)
posthook = proc do
  mkconfig = RbConfig::MAKEFILE_CONFIG
  extout = File.expand_path(mkconfig["EXTOUT"], builddir)
  $arch_hdrdir = "#{extout}/include/$(arch)"
  $ruby = baseruby
  untrace_var(:$ruby, posthook)
end
prehook = proc do |extmk|
  unless extmk
    config = RbConfig::CONFIG
    mkconfig = RbConfig::MAKEFILE_CONFIG
    mkconfig["top_srcdir"] = $top_srcdir = File.expand_path(".", builddir)
    mkconfig["rubyhdrdir"] = "$(top_srcdir)/include"
    mkconfig["builddir"] = config["builddir"] = builddir
    config["rubyhdrdir"] = File.join(mkconfig["top_srcdir"], "include")
    mkconfig["libdir"] = config["libdir"] = mkconfig["topdir"]
    trace_var(:$ruby, posthook)
  end
  untrace_var(:$extmk, prehook)
end
trace_var(:$extmk, prehook)
