class BinutilsM6809 < Formula
  desc "Binutils for M6809 MPU, based on ASxxxx"
  homepage "https://code.google.com/archive/p/gcc6809/"
  url "https://ftpmirror.gnu.org/gcc/gcc-4.3.6/gcc-4.3.6.tar.bz2"
  sha256 "f3765cd4dcceb4d42d46f0d53471d7cedbad50f2112f0312c1dcc9c41eea9810"
  version "5.1.1"
  revision 20180727

  patch do
    url "https://gitlab.com/tgtakaoka/gcc6809/raw/gcc6809-patch/gcc6809-4.3.6-dftools-20180727.patch.gz"
    sha256 "29ef896fa00efae81066d070de842e6834a8c232abbbef73cedd6834729e1860"
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
