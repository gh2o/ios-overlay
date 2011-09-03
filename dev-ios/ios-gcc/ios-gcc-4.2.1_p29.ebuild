ETYPE="gcc-compiler"
CTARGET="arm-apple-darwin10"

inherit toolchain versionator

LICENSE="GPL-3"
KEYWORDS="~amd64"

DEPEND="
	dev-ios/ios-cctools
	dev-ios/ios-sdk
"
RDEPEND="${DEPEND}"

PATCHLEVEL="${PV#*_p}"
LLVM_MAJOR="$((${PATCHLEVEL} / 10))"
LLVM_MINOR="$((${PATCHLEVEL} % 10))"
LLVM_VERSION="${LLVM_MAJOR}.${LLVM_MINOR}"

EXTRA_ECONF="${EXTRA_ECONF} --enable-languages=c,c++,objc,obj-c++"

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
}
