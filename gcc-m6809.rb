class GccM6809 < Formula
  desc "GNU C compiler for M6809 MPU"
  homepage "https://code.google.com/archive/p/gcc6809/"
  url "https://ftpmirror.gnu.org/gcc/gcc-4.3.6/gcc-4.3.6.tar.bz2"
  sha256 "f3765cd4dcceb4d42d46f0d53471d7cedbad50f2112f0312c1dcc9c41eea9810"
  version "4.3.6-20190308"
  revision 2

  depends_on "binutils-m6809"
  depends_on "mpfr" => :build if OS.mac?
  depends_on "gmp" => :build if OS.mac?
  depends_on "libmpc" => :build if OS.mac?

  patch do
    url "https://gitlab.com/tgtakaoka/gcc6809/raw/gcc6809-patch/gcc6809-4.3.6-dftools-20190308.patch.gz"
    sha256 "59a6b2cf537d14b1ffbfa48674292088c4b18cb0bff27ae9a8e84b2986161016"
  end

  resource "config" do
    url "https://git.savannah.gnu.org/git/config.git"
    patch do
      url "https://gitlab.com/tgtakaoka/gcc6809/raw/gcc6809-patch/config.sub-20190105-m6809.patch"
      sha256 "2b23fa824a0ca2c89cb415c4c17e29063056f6fb96ffa10d680fecb7b7467bb1"
    end
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
      args = []
      args << "prefix=#{prefix}"
      args << "GCC_LANGUAGES=c"
      args << "SUDO="
      system "make", *args, "config"
      system "make", *args, "build"
      ENV.deparallelize
      system "make", *args, "install"
    end

    # Move man1 under share/man and remove unnecessary files.
    man.install prefix/"man/man1"
    (prefix/"info").rmtree
    (prefix/"man").rmtree
    (lib/"libiberty.a").delete
    # Remove empty target/lib directory not to confuse install_symlink below.
    (prefix/target/"lib").rmtree

    # Create empty place holders for libc-m6809.
    target_lib = HOMEBREW_PREFIX/"lib/#{target}/lib"
    target_include = HOMEBREW_PREFIX/"include/#{target}/include"
    target_lib.mkpath
    target_include.mkpath

    # Create symlinks to libc-m6809.
    (prefix/target).install_symlink target_lib
    (prefix/target).install_symlink target_include
  end
end
