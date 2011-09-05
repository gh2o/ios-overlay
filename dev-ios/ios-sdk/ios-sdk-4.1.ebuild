# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

DESCRIPTION="iPhone headers and libs from xcode"
HOMEPAGE="http://developer.apple.com/xcode/"

LICENSE="Apple"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RESTRICT="fetch strip"
DEPEND="
	app-arch/p7zip
"

XCODE="xcode_4.1_for_lion.dmg"
IOS_VERSION="4.3"

SRC_URI="${XCODE}"

S="${WORKDIR}"
SS="${S}/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS${IOS_VERSION}.sdk"

src_unpack () {
	7z x -so "${DISTDIR}/${XCODE}" 5.hfs >xcode.img || die "7z failed"

	7z x -so xcode.img "Install Xcode/InstallXcodeLion.pkg" >xcode.pkg || die "7z failed"
	rm xcode.img

	7z x -so xcode.pkg InstallXcodeLion.pkg/Payload | \
		cpio -i --to-stdout  "./Applications/Install Xcode.app/Contents/Resources/Packages/iPhoneSDK${IOS_VERSION/./_}.pkg" > \
		ios.pkg
	rm xcode.pkg

	7z x -so ios.pkg Payload | gzip -d | cpio -id
	rm ios.pkg
}

src_compile () {
	cd "${SS}/System/Library/Frameworks"
	for ff in *.framework; do
		f="${ff%.framework}"
		i="${SS}/usr/include/${f}"
		h="${ff}/Headers"

		if [ -d "${h}" ]; then
			mkdir -pv "${i}"
			cp -rv "${h}"/* "${i}"
			rm -r "${h}"
		fi
	done
}

src_install () {
	sysroot="${D}/usr/arm-apple-darwin10"

	mkdir -pv "${sysroot}"
	cp -rv "${SS}"/{usr,System} "${sysroot}" || die "copy failed"

	ln -s usr/include "${sysroot}/sys-include"
}
