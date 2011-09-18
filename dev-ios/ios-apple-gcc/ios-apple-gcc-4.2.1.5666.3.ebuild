# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
ETYPE="gcc-compiler"
CTARGET="arm-apple-darwin10"

inherit toolchain versionator

TOOLCHAIN_STDCXX_INCDIR="/usr/${CTARGET}/usr/include/c++/${GCC_RELEASE_VER}"
STDCXX_INCDIR="${TOOLCHAIN_STDCXX_INCDIR}"

GCC_APPLE_VERSION="$(get_version_component_range 4-)"

DESCRIPTION="Apple branch of the GNU Compiler Collection, compiled with iOS target"
HOMEPAGE="http://gcc.gnu.org/"
SRC_URI="http://www.opensource.apple.com/tarballs/gcc/gcc-${GCC_APPLE_VERSION}.tar.gz"

LICENSE="GPL-2 GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

BUILDDIR="${WORKDIR}/build"

pkg_setup () {
	gcc_do_filter_flags
}

gcc_quick_unpack () {
	unpack ${A}
	mv "gcc-${GCC_APPLE_VERSION}" "${S}"

	# fix ctype.h conflict
	sed -i -e '/safe-ctype.h and ctype.h/d' \
		"${S}/include/safe-ctype.h" || die

	# armv5 is no longer supported
	sed -i -e 's/armv5 armv6 armv7/armv6 armv7/g' \
		"${S}/gcc/config/arm/t-darwin" || die
}

src_configure () {
	mkdir -p "${BUILDDIR}"
	cd "${BUILDDIR}"
	gcc_do_configure
}

src_compile () {
	cd "${BUILDDIR}"
	gcc_do_make
}
