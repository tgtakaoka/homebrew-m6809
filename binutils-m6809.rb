class BinutilsM6809 < Formula
  desc "Binutils for M6809 MPU, based on ASxxxx"
  homepage "https://code.google.com/archive/p/gcc6809/"
  url "https://ftpmirror.gnu.org/gcc/gcc-4.3.6/gcc-4.3.6.tar.bz2"
  sha256 "f3765cd4dcceb4d42d46f0d53471d7cedbad50f2112f0312c1dcc9c41eea9810"
  version "5.1.1-20190307"
  revision 1

  patch do
    url "https://gitlab.com/tgtakaoka/gcc6809/raw/gcc6809-patch/gcc6809-4.3.6-dftools-20190307.patch.gz"
    sha256 "739b751e7dd6b2dc9f8552f6835758559ee0e4b3cd3e53ed06de2c9d28113de2"
  end

  def install
    target = "m6809-unknown-none"
    Dir.chdir "build-6809" do
      inreplace "Makefile", "$(PWD)", "#{buildpath}/build-6809"
      args = []
      args << "prefix=#{prefix}"
      args << "SUDO="
      system "make", *args, "asm"
      ENV.deparallelize
      system "make", *args, "asm-install"
      system "make", *args, "binutils"
    end

    # Move no-prefix binaries from bin to bin/target.
    target_bin = bin/target
    target_bin.install bin/"as6809", bin/"aslink", bin/"aslib"
    inreplace bin/"#{target}-as", "bindir=${as_prefix}/bin", "bindir=#{target_bin}"
    inreplace bin/"#{target}-ld", "bindir=${as_prefix}/bin", "bindir=#{target_bin}"
    inreplace bin/"#{target}-ar", "bindir=${as_prefix}/bin", "bindir=#{target_bin}"

    # Create empty place holders for gcc-m6809 and libc-m6809.
    (lib/target/"lib/.#{name}").write ''
    (include/target/"include/.#{name}").write ''
  end
end
