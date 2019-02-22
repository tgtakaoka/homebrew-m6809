class GdbM6809 < Formula
  desc "GNU debugger for M6809 MPU"
  homepage "http://www.6809.org.uk/dragon/m6809-gdb.shtml"
  url "https://ftpmirror.gnu.org/gdb/gdb-7.6.2.tar.bz2"
  sha256 "2f6a0e2ce1c66c9dedeb7f58a8d1298ad602ddcdaf15d23104e1f7832b96d0e8"
  revision 20190223

  patch do
    url "https://gitlab.com/tgtakaoka/gdb6809/raw/gdb6809-patch/gdb6809-7.6.2-20190223.patch.gz"
    sha256 "ccc6b14f6c7820b7fbf41fb3bf5f2d7ba5eea5b85b75b88bd722c244bc1aeec0"
  end

  def install
    target = "m6809-unknown-none"
    mkdir "build" do
      system "../configure",
        "--target=#{target}",
	"--program-prefix=#{target}-",
        "--prefix=#{prefix}",
        "--with-system-zlib",
	"--disable-etc",
        "--with-python=no",
        "--disable-nls",
        "--disable-werror"
      system "make"
      system "make", "install"

      lib.rmtree
      (share/"gdb").rmtree
      include.rmtree
      info.rmtree
    end
  end
end
