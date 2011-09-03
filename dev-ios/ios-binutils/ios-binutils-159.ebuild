EAPI="4"

inherit subversion autotools eutils

DESCRIPTION="binutils for iPhone"

CCTOOLS_VERSION="782"
LD64_VERSION="85.2.2"

ESVN_REPO_URI="http://svn.macosforge.org/repository/odcctools/trunk/@159"
SRC_URI="
	http://www.opensource.apple.com/tarballs/cctools/cctools-${CCTOOLS_VERSION}.tar.gz
	http://www.opensource.apple.com/tarballs/ld64/ld64-${LD64_VERSION}.tar.gz
"

EPATCH_OPTS=""

LICENSE="APSL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

CTARGET="arm-apple-darwin10"

pkg_setup () {
	S="${WORKDIR}/build"
	replace-flags -O? -O0
}

src_unpack () {
	S="${WORKDIR}"
	subversion_src_unpack
	
	S="${WORKDIR}/build"
	mkdir "${S}"
	
	cd "${S}"
	unpack "cctools-${CCTOOLS_VERSION}.tar.gz"
	mv cctools-${CCTOOLS_VERSION}/* .
	rmdir cctools-${CCTOOLS_VERSION}
	
	mkdir ld64
	cd ld64
	unpack "ld64-${LD64_VERSION}.tar.gz"
	mv ld64-${LD64_VERSION}/* .
	rmdir ld64-${LD64_VERSION}
	
	cd "${S}"
	cp -r ../files/* .
}

src_prepare () {
	find "${S}" -type f -name '*.[ch]' | while read f; do
		sed -i -e 's/^#import/#include/' $f
	done
	
	find "${S}" -type f -name '*.[h]' | while read f; do
		sed -i -e 's/^__private_extern__/extern/' $f
	done

	find "${S}/ld64/doc" -type f -exec mv {} "${S}/man" \;

	cd "${WORKDIR}/patches"
	epatch "${FILESDIR}/odcctools-159-patches-patch.diff"
	cd "${S}"
	epatch "${FILESDIR}/odcctools-159-fix-types.diff"
	epatch "${FILESDIR}/odcctools-159-ld64.diff"

	patches="ar/archive.diff ar/ar-printf.diff ar/ar-ranlibpath.diff \
	ar/contents.diff ar/declare_localtime.diff ar/errno.diff as/arm.c.diff \
	as/bignum.diff as/driver.c as/getc_unlocked.diff as/input-scrub.diff \
	as/messages.diff as/relax.diff as/use_PRI_macros.diff \
	include/mach/machine.diff include/stuff/bytesex-floatstate.diff \
	ld64/FileAbstraction-inline.diff ld64/ld_cpp_signal.diff \
	ld64/Options-config_h.diff ld64/Options-ctype.diff \
	ld64/Options-defcross.diff ld64/Options_h_includes.diff \
	ld64/Options-stdarg.diff ld64/remove_tmp_math_hack.diff \
	ld64/Thread64_MachOWriterExecutable.diff ld-sysroot.diff \
	ld/uuid-nonsmodule.diff libstuff/default_arch.diff \
	libstuff/macosx_deployment_target_default_105.diff \
	libstuff/map_64bit_arches.diff libstuff/sys_types.diff \
	misc/libtool-ldpath.diff misc/libtool-pb.diff misc/ranlibname.diff \
	misc/redo_prebinding.nogetattrlist.diff \
	misc/redo_prebinding.nomalloc.diff misc/libtool_lipo_transform.diff \
	otool/nolibmstub.diff otool/noobjc.diff \
	ld64/LTOReader-setasmpath.diff include/mach/machine_armv7.diff \
	ld/ld-nomach.diff libstuff/cmd_with_prefix.diff ld64/cstdio.diff \
	misc/with_prefix.diff misc/bootstrap_h.diff"
	
	pd="${WORKDIR}/patches"
	for pt in ${patches}; do
		cd "${S}/$(dirname ${pt})"
		epatch "${pd}/${pt}"
	done

	cd "${S}"

	sed -i 's/round\.c/rnd\.c/g' libstuff/Makefile.in
	find . -type f -print0 | xargs -0 sed -i 's/#import/#include/g'

	sed -i 's/>=8/-ge 8/g' configure.ac
	eautoreconf
}

src_configure () {
	econf \
		--target=${CTARGET} \
		--enable-as-targets=arm \
		--with-sysroot=/usr/${CTARGET}
}

src_install () {
	emake DESTDIR="${D}" install

	for m in `seq 1 8`; do
		d="${D}/usr/share/man/man${m}"

		if ! [ -d "${d}" ]; then
			continue
		fi

		cd "${d}"
		for p in *; do
			n="${p%.*}_odcctools"
			mv "${p}" "${n}.${m}"
		done
	done
}
