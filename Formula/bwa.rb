class Bwa < Formula
  desc "Burrow-Wheeler Aligner for pairwise alignment of DNA"
  homepage "https://github.com/lh3/bwa"
  url "https://github.com/lh3/bwa/releases/download/v0.7.16/bwa-0.7.16a.tar.bz2"
  sha256 "8fecdb5f88871351bbe050c18d6078121456c36ad75c5c78f33a926560ffc170"
  head "https://github.com/lh3/bwa.git"

  def install
    system "make", "CC=#{ENV.cc}", "CFLAGS=#{ENV.cflags}"
    bin.install "bwa"
    doc.install "README.md", "NEWS.md"
    man1.install "bwa.1"
  end

  test do
    (testpath/"test.fasta").write ">0\nAGATGTGCTG\n"
    system "#{bin}/bwa", "index", "test.fasta"
    assert_predicate testpath/"test.fasta.bwt", :exist?
    assert_match "AGATGTGCTG", shell_output("#{bin}/bwa mem test.fasta test.fasta")
  end
end
