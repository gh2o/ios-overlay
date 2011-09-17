# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="iOS toolchain metapackage"
HOMEPAGE="https://github.com/gh2o/ios-overlay"
SRC_URI=""

LICENSE="Apple"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="
	dev-ios/ios-sdk
	|| (
		dev-ios/ios-new-binutils
		dev-ios/ios-binutils
	)
	|| (
		dev-ios/ios-apple-gcc
		dev-ios/ios-llvm-gcc
	)
"
