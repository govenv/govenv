class Govenv < Formula
  desc "Go venv management"
  homepage "https://github.com/govenv/govenv"
  url "https://github.com/govenv/govenv/archive/v0.0.1.tar.gz"
  sha256 "f0728660bb6c8e5513457520bc843ce8b9dc282d615b1cb296f8ff6c02b597d9"
  version_scheme 1
  head "https://github.com/govenv/govenv.git"

  bottle :unneeded

  def install
    inreplace "libexec/govenv", "/usr/local", HOMEBREW_PREFIX
    prefix.install Dir["*"]
    %w[govenv-install govenv-uninstall go-build].each do |cmd|
      bin.install_symlink "#{prefix}/plugins/go-build/bin/#{cmd}"
  end

  test do
    system "false"
  end
end
