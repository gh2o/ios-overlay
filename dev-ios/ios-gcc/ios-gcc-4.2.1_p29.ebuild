# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ETYPE="gcc-compiler"
CTARGET="arm-apple-darwin10"
TOOLCHAIN_STDCXX_INCDIR="/usr/${CTARGET}/usr/include/c++/${PV%_*}"

inherit toolchain versionator

DECRIPTION="GCC for iPhone"
HOMEPAGE="http://www.llvm.org/"
LICENSE="GPL-3"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	|| (
		dev-ios/ios-new-binutils
		dev-ios/ios-binutils
	)
	dev-ios/ios-sdk
"
RDEPEND="${DEPEND}"

PATCHLEVEL="${PV#*_p}"
LLVM_MAJOR="$((${PATCHLEVEL} / 10))"
LLVM_MINOR="$((${PATCHLEVEL} % 10))"
LLVM_VERSION="${LLVM_MAJOR}.${LLVM_MINOR}"

LLVM_GCC_NAME="llvm-gcc-${GCC_BRANCH_VER}-${LLVM_VERSION}.source"
SRC_URI="http://www.llvm.org/releases/${LLVM_VERSION}/${LLVM_GCC_NAME}.tgz"

gcc_quick_unpack () {
	true
}

src_unpack () {
	unpack ${A}
	mv "${LLVM_GCC_NAME}" "${S}"
	gcc_src_unpack

	cd "${S}"

	# lipo needs prefix
	sed -i -e "s|lipo|${CTARGET}-lipo|g" ./gcc/Makefile.in

	# move LLVM headers to end of search path
	sed -i -e 's|INCLUDES += -I|INCLUDES += -isystem |g' gcc/Makefile.in

	# patch redef of mempcpy
	sed -i -e 's|extern char \* mempcpy|//|g' ./gcc/config/darwin.c

	# ios sdk doesn't support armv5
	sed -i -e 's|armv5 armv6 armv7|armv6 armv7|g' gcc/config/arm/t-darwin
}

src_compile () {
	# llvm-specific options
	eval "$(declare -f gcc_src_compile | tail -n +2 | sed \
		-e 's|gcc_do_configure|& --enable-llvm=/usr|g')"
}
