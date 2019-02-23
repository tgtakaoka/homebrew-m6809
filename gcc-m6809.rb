class GccM6809 < Formula
  desc "GNU C compiler for M6809 MPU"
  homepage "https://code.google.com/archive/p/gcc6809/"
  url "https://ftpmirror.gnu.org/gcc/gcc-4.3.6/gcc-4.3.6.tar.bz2"
  sha256 "f3765cd4dcceb4d42d46f0d53471d7cedbad50f2112f0312c1dcc9c41eea9810"
  revision 20190210

  depends_on "binutils-m6809"
  depends_on "mpfr" => :build if OS.mac?
  depends_on "gmp" => :build if OS.mac?
  depends_on "libmpc" => :build if OS.mac?

  patch do
    url "https://gitlab.com/tgtakaoka/gcc6809/raw/gcc6809-patch/gcc6809-4.3.6-dftools-20190210.patch.gz"
    sha256 "54dabbbbca87f08aeb5ebe056baec53145dc2358df5b6e420cc4867e89be7ce6"
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

    (prefix/"info").rmtree
    man.install Dir["#{prefix}/man/man1"]
    (prefix/"man").rmtree

    (lib/"libiberty.a").delete
    target_lib = HOMEBREW_PREFIX/"lib/#{target}/lib"
    (prefix/target/"lib").rmtree
    (prefix/target).install_symlink target_lib

    target_include = HOMEBREW_PREFIX/"include/#{target}/include"
    (prefix/target).install_symlink target_include
  end
end
