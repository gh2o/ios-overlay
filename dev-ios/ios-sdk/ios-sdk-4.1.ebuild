EAPI="4"

DESCRIPTION="iPhone headers and libs from xcode"

LICENSE="Apple"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RESTRICT="fetch strip"
DEPENDS="
	app-arch/p7zip
"

XCODE="xcode_4.1_for_lion.dmg"
SRC_URI="${XCODE}"

S="${WORKDIR}"
SS="${S}/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS4.3.sdk"

src_unpack () {
	7z x -so "${DISTDIR}/${XCODE}" 5.hfs >xcode.img || die "7z failed"
	
	7z x -so xcode.img "Install Xcode/InstallXcodeLion.pkg" >xcode.pkg || die "7z failed"
	rm xcode.img

	7z x -so xcode.pkg InstallXcodeLion.pkg/Payload | \
		cpio -i --to-stdout  "./Applications/Install Xcode.app/Contents/Resources/Packages/iPhoneSDK4_3.pkg" > \
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
