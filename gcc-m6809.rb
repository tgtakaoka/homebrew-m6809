class GccM6809 < Formula
  desc "GNU C ompiler for M6809 MPU"
  homepage "https://code.google.com/archive/p/gcc6809/"
  url "https://ftpmirror.gnu.org/gcc/gcc-4.3.6/gcc-4.3.6.tar.bz2"
  sha256 "f3765cd4dcceb4d42d46f0d53471d7cedbad50f2112f0312c1dcc9c41eea9810"
  revision 20170517

  depends_on "binutils-m6809"
  depends_on "mpfr" => :build if OS.mac?
  depends_on "gmp" => :build if OS.mac?
  depends_on "libmpc" => :build if OS.mac?

  patch do
    url "https://gitlab.com/tgtakaoka/gcc6809/raw/gcc6809-patch/gcc6809-4.3.6-dftools-20170517.patch.gz"
    sha256 "dc8bf8be92ef2fd3adcdead5930aaa526a556f23091b4f9c4a4a608b5e63ea6b"
  end

  resource "config" do
    url "https://git.savannah.gnu.org/git/config.git"
  end

  def install
    # Update config.guess and config.sub to be able to handle newer
    # architechture such as aarch64.
    resource("config").stage do
      buildpath.install "config.guess"
      buildpath.install "config.sub"
    end

    target = "m6809-unknown-none"
    Dir.chdir "build-6809" do
      mkdir target
      inreplace "Makefile",
                "run_binutil = $(prefix)/bin/",
                "run_binutil = #{HOMEBREW_PREFIX}/bin/"
      inreplace "Makefile", "$(PWD)", "#{buildpath}/build-6809"
      system "make",
             "prefix=#{prefix}",
             "GCC_LANGUAGES=c",
             "config"
      system "make",
             "prefix=#{prefix}",
             "GCC_LANGUAGES=c",
             "build"
      ENV.deparallelize
      system "make",
             "prefix=#{prefix}",
             "GCC_LANGUAGES=c",
             "SUDO=",
             "install"
    end

    (lib/"libiberty.a").delete

    target_lib = HOMEBREW_PREFIX/"lib/#{target}/lib"
    (lib/target).install Dir["#{prefix}/#{target}/lib/*"]
    (prefix/target/"lib").rmtree
    (prefix/target).install_symlink target_lib

    target_include = HOMEBREW_PREFIX/"include/#{target}/include"
    (prefix/target).install_symlink target_include
  end
end
