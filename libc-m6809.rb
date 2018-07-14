class LibcM6809 < Formula
  desc "Newlib, C library for M6809 MPU"
  homepage "https://sourceforge.net/projects/mspgcc/"
  url "ftp://sourceware.org/pub/newlib/newlib-1.15.0.tar.gz"
  sha256 "c4496102d38c59d1a47ddd5481af35caa1f65b76e2a94d9607737e17fd9e4465"
  revision 20170508

  depends_on "gcc-m6809"

  patch do
    url "https://gitlab.com/tgtakaoka/newlib-6809/raw/newlib-m6809-patch/newlib-m6809-1.15-dev-20170508.patch.gz"
    sha256 "4e66c6caa21feb3ee044f2162e4723c8a212b15c414018ceb3f26d2caa7cda10"
  end

  resource "config" do
    url "https://git.savannah.gnu.org/git/config.git"
    patch do
      url "https://gitlab.com/tgtakaoka/newlib-6809/raw/newlib-m6809-patch/config.sub-m6809.patch"
      sha256 "1c1c256e05ce273c287eb27252f1247917fe7d40bcb86e9f48a1193990a62b79"
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
    Dir.chdir "build" do
      inreplace "newlib.6809", "prefix:-/usr/local", "prefix:-#{prefix}"
      inreplace "newlib.6809", "target:-m6809-sim-none", "target:-#{target}"
      inreplace "newlib.6809", "sudo:-sudo", "sudo:-"
      inreplace "newlib.6809", "${prefix}/bin/", "#{HOMEBREW_PREFIX}/bin/"
      # Homebrew set ENV["CC"] to the host compiler but it confuses newlib.
      ENV.delete("CC")
      system "sh", "newlib.6809", "config"
      system "sh", "newlib.6809", "make"
      system "sh", "newlib.6809", "install"
    end

    target_lib = lib/target/"lib"
    target_lib.install Dir["#{prefix}/#{target}/lib/*"]

    target_include = include/target/"include"
    target_include.install Dir["#{prefix}/#{target}/include/*"]
  end
end
