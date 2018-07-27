class BinutilsM6809 < Formula
  desc "Binutils for M6809 MPU, based on ASxxxx"
  homepage "https://code.google.com/archive/p/gcc6809/"
  url "https://ftpmirror.gnu.org/gcc/gcc-4.3.6/gcc-4.3.6.tar.bz2"
  sha256 "f3765cd4dcceb4d42d46f0d53471d7cedbad50f2112f0312c1dcc9c41eea9810"
  version "5.1.1"
  revision 20170517

  patch do
    url "https://gitlab.com/tgtakaoka/gcc6809/raw/gcc6809-patch/gcc6809-4.3.6-dftools-20170517.patch.gz"
    sha256 "dc8bf8be92ef2fd3adcdead5930aaa526a556f23091b4f9c4a4a608b5e63ea6b"
  end
  patch do
    url "https://raw.githubusercontent.com/tgtakaoka/homebrew-gcc6809/fix-macos-build/patches/fix-ranlib.patch"
    sha256 "952f025ac140859df7e373cd6062340387661103ea414808787cdf50b3c528fd"
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

    (bin/target).install bin/"as6809"
    (bin/target).install bin/"aslink"
    (bin/target).install bin/"aslib"
    inreplace bin/"#{target}-as", "bindir=${as_prefix}/bin", "bindir=${as_prefix}/bin/#{target}"
    inreplace bin/"#{target}-ld", "bindir=${as_prefix}/bin", "bindir=${as_prefix}/bin/#{target}"
    inreplace bin/"#{target}-ar", "bindir=${as_prefix}/bin", "bindir=${as_prefix}/bin/#{target}"
  end
end
