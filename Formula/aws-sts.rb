# typed: false
# frozen_string_literal: true

# This file was generated by GoReleaser. DO NOT EDIT.
require_relative "../lib/private"
class AwsSts < Formula
  desc "Install tools"
  homepage "https://github.com/oals-dev/homebrew-tap"
  version "0.0.5"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/oals-dev/aws-sts/releases/download/v0.0.5/aws-sts_0.0.5_Darwin_arm64.tar.gz", :using => GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "bfba6421edc29613977ca9f53eb3cb57a3f1e22de06e1f885d91c5c4348a7139"

      def install
        bin.install "aws-sts"
      end
    end
    if Hardware::CPU.intel?
      url "https://github.com/oals-dev/aws-sts/releases/download/v0.0.5/aws-sts_0.0.5_Darwin_x86_64.tar.gz", :using => GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "ed68d086193f56430e7e74958db57b22cddf0f2b30d482cff770f1bfbf211070"

      def install
        bin.install "aws-sts"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/oals-dev/aws-sts/releases/download/v0.0.5/aws-sts_0.0.5_Linux_arm64.tar.gz", :using => GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "4b60c70a77aec0821ab1b233657a1b1ac0105ee319109fe36a3028383a9a3d33"

      def install
        bin.install "aws-sts"
      end
    end
    if Hardware::CPU.intel?
      url "https://github.com/oals-dev/aws-sts/releases/download/v0.0.5/aws-sts_0.0.5_Linux_x86_64.tar.gz", :using => GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "a2a6446053ca61221e4dfe6f2124428b3ead31c6317d55a0bd1a742737818ba4"

      def install
        bin.install "aws-sts"
      end
    end
  end

  test do
    system "#{bin}/aws-sts -v"
  end
end
