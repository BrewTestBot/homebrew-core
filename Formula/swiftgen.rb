class Swiftgen < Formula
  desc "Collection of Swift tools to generate Swift code"
  homepage "https://github.com/AliSoftware/SwiftGen"
  url "https://github.com/AliSoftware/SwiftGen/archive/4.0.1.tar.gz"
  sha256 "4646b7c71523dc51d5c298c67aa4a8cf542f8788b5cdbebf4b8179de2fdcacc1"
  head "https://github.com/AliSoftware/SwiftGen.git"

  bottle do
    cellar :any
    rebuild 1
    sha256 "92474de4c0d8aa7432c4fd9e104855643aa5750391aead70e8b7f2fba2405e2b" => :sierra
    sha256 "b37b2adcce2dc3339c7ff57940dc447ba329b01442b7ac6969908a6b53ae6b3c" => :el_capitan
  end

  depends_on :xcode => ["8.0", :build]

  def install
    rake "install[#{bin},#{lib},#{pkgshare}/templates]"

    fixtures = %w[
      UnitTests/fixtures/Images.xcassets
      UnitTests/fixtures/colors.txt
      UnitTests/fixtures/Localizable.strings
      UnitTests/fixtures/Storyboards-iOS/Message.storyboard
      UnitTests/fixtures/Fonts
      UnitTests/expected/Images-File-Default.swift.out
      UnitTests/expected/Colors-Txt-File-Default.swift.out
      UnitTests/expected/Strings-File-Default.swift.out
      UnitTests/expected/Storyboards-Message-Default.swift.out
      UnitTests/expected/Fonts-Dir-Default.swift.out
    ]
    (pkgshare/"fixtures").install fixtures
  end

  test do
    system bin/"swiftgen", "--version"

    fixtures = pkgshare/"fixtures"

    output = shell_output("#{bin}/swiftgen images --templatePath #{pkgshare/"templates/images-default.stencil"} #{fixtures}/Images.xcassets").strip
    assert_equal output, (fixtures/"Images-File-Default.swift.out").read.strip, "swiftgen images failed"

    output = shell_output("#{bin}/swiftgen colors --templatePath #{pkgshare/"templates/colors-default.stencil"} #{fixtures}/colors.txt").strip
    assert_equal output, (fixtures/"Colors-Txt-File-Default.swift.out").read.strip, "swiftgen colors failed"

    output = shell_output("#{bin}/swiftgen strings --templatePath #{pkgshare/"templates/strings-default.stencil"} #{fixtures}/Localizable.strings").strip
    assert_equal output, (fixtures/"Strings-File-Default.swift.out").read.strip, "swiftgen strings failed"

    output = shell_output("#{bin}/swiftgen storyboards --templatePath #{pkgshare/"templates/storyboards-default.stencil"} #{fixtures}/Message.storyboard").strip
    assert_equal output, (fixtures/"Storyboards-Message-Default.swift.out").read.strip, "swiftgen storyboards failed"

    output = shell_output("#{bin}/swiftgen fonts --templatePath #{pkgshare/"templates/fonts-default.stencil"} #{fixtures}/Fonts").strip
    assert_equal output, (fixtures/"Fonts-Dir-Default.swift.out").read.strip, "swiftgen fonts failed"
  end
end
