ETYPE="gcc-compiler"
CTARGET="arm-apple-darwin10"

inherit toolchain versionator

LICENSE="GPL-3"
KEYWORDS="~amd64"

DEPEND="
	dev-ios/ios-binutils
	dev-ios/ios-sdk
"
RDEPEND="${DEPEND}"

PATCHLEVEL="${PV#*_p}"
LLVM_MAJOR="$((${PATCHLEVEL} / 10))"
LLVM_MINOR="$((${PATCHLEVEL} % 10))"
LLVM_VERSION="${LLVM_MAJOR}.${LLVM_MINOR}"

# llvm-specific options
EXTRA_ECONF="
	--enable-languages=c,c++,objc,obj-c++
	--enable-llvm=/usr
	${EXTRA_ECONF}
"

# ios sdk doesn't support armv5
EXTRA_EMAKE='
	ARM_MULTILIB_ARCHS="armv6 armv7"
'

get_llvm_gcc_name () {
	set -- $(get_all_version_components)
	GCC_MAJOR_MINOR="${1}${2}${3}"
	echo "llvm-gcc-${GCC_MAJOR_MINOR}-${LLVM_VERSION}.source"
}

LLVM_GCC_NAME="$(get_llvm_gcc_name)"
SRC_URI="http://www.llvm.org/releases/${LLVM_VERSION}/${LLVM_GCC_NAME}.tgz"

gcc_quick_unpack () {
	true
}

src_unpack () {
	unpack "${A}"
	mv "${LLVM_GCC_NAME}" "${S}"
	gcc_src_unpack	

	cd "${S}"

	# lipo needs prefix
	sed -i -e "s|lipo|${CTARGET}-lipo|g" ./gcc/Makefile.in

	# move LLVM headers to end of search path
	sed -i -e 's|INCLUDES += -I|INCLUDES += -isystem |g' gcc/Makefile.in

	# patch redef of mempcpy
	sed -i -e 's|extern char \* mempcpy|//|g' ./gcc/config/darwin.c
}
