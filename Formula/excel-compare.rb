class ExcelCompare < Formula
  desc "Command-line tool (and API) for diffing Excel Workbooks"
  homepage "https://github.com/na-ka-na/ExcelCompare"
  url "https://github.com/na-ka-na/ExcelCompare/releases/download/0.6.0/ExcelCompare-0.6.0.zip"
  sha256 "63bda982644ec8633b60eed5bc199892c428b54addb2eb63dda0b894d98a56c4"

  resource "sample_workbook" do
    url "https://github.com/na-ka-na/ExcelCompare/raw/0.6.0/test/resources/ss1.xlsx"
    sha256 "f362153aea24092e45a3d306a16a49e4faa19939f83cdcb703a215fe48cc196a"
  end

  def install
    libexec.install Dir["bin/dist/*"]

    (bin/"excel_cmp").write <<-EOS.undent
      #!/bin/sh
      java -ea -Xmx512m -cp "#{libexec}/*" com.ka.spreadsheet.diff.SpreadSheetDiffer "$@"
    EOS
  end

  test do
    ss1path = testpath/"ss1"
    resource("sample_workbook").stage ss1path
    ss1path.cd do
      # xlsx files are just zip archives, so Homebrew unpacks them automatically.
      # We need to reconstruct the xlsx file before running excel_cmp
      system "/usr/bin/zip", "-r", "ss1.xlsx", "."
      assert_match /Excel files ss1.xlsx and ss1.xlsx match/,
        shell_output("#{bin}/excel_cmp ss1.xlsx ss1.xlsx")
    end
  end
end
