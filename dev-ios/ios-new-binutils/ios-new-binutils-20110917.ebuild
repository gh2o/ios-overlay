# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit multilib flag-o-matic

DESCRIPTION="Darwin cctools and ld64 ported to Linux"
HOMEPAGE="https://github.com/gh2o/darwin-cctools"
LICENSE="GPL-3 APSL-2 Apple"
SLOT="0"
RESTRICT="mirror"
IUSE="llvm"

DEPEND="llvm? ( sys-devel/llvm )"
RDEPEND="${DEPEND}"

KEYWORDS="~amd64 ~x86"

GITHUB_USER="gh2o"
GITHUB_REPO="darwin-cctools"
GITHUB_COMMIT="50bff25"

SRC_URI="https://github.com/${GITHUB_USER}/${GITHUB_REPO}/tarball/${GITHUB_COMMIT}
	-> ${P}-${GITHUB_COMMIT}.tar.gz"
SRC_DIR="${GITHUB_USER}-${GITHUB_REPO}-${GITHUB_COMMIT}"

S="${WORKDIR}/darwin-cctools"

CTARGET="arm-apple-darwin10"

BVER=${PV}
LIBPATH=/usr/$(get_libdir)/binutils/${CTARGET}/${BVER}
INCPATH=${LIBPATH}/include
DATAPATH=/usr/share/binutils-data/${CTARGET}/${BVER}
BINPATH=/usr/${CHOST}/${CTARGET}/binutils-bin/${BVER}

src_unpack () {
	unpack ${A}
	mv "${SRC_DIR}" "${S}"
}

src_configure () {
	replace-flags -O? -O0

	set -- ./configure \
		--prefix=/usr \
		--host=${CHOST} \
		--target=${CTARGET} \
		--datadir=${DATAPATH} \
		--infodir=${DATAPATH}/info \
		--mandir=${DATAPATH}/man \
		--bindir=${BINPATH} \
		--libdir=${LIBPATH} \
		--libexecdir=${LIBPATH} \
		--includedir=${INCPATH} \
		--program-transform-name='' \
		$(use_enable llvm llvm /usr) \
		--with-sysroot=/usr/${CTARGET} \
		--enable-silent-rules \
		${EXTRA_ECONF}

	echo "$@"
	"$@" || die
}

src_compile () {
	emake all
}

src_install () {
	emake DESTDIR="${D}" install
	docompress "${DATAPATH}/man"

	# don't throw binutils-config off
	dodir "${LIBPATH}"

	cd "${T}"
	cat > env.d <<- EOF
		TARGET="${CTARGET}"
		VER="${PV}"
		FAKE_TARGETS="${CTARGET}"
	EOF

	insinto /etc/env.d/binutils
	newins env.d "${CTARGET}-${PV}"
}

pkg_postinst () {
	binutils-config "${CTARGET}-${PV}"
}
