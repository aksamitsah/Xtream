#!/bin/bash
# Disable package and macro fingerprint validation to enable the SwiftLint plugin during the build process.
defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES
