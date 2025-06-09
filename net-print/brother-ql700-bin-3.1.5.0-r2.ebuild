# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit rpm multilib

DESCRIPTION="Brother printer driver for QL-700 label printer"

HOMEPAGE="http://support.brother.com"

SRC_URI="https://download.brother.com/welcome/dlfp002191/ql700pdrv-3.1.5-0.i386.rpm"

LICENSE="brother-eula"

SLOT="0"

KEYWORDS="~amd64"

IUSE=""

RESTRICT="mirror strip"

DEPEND="net-print/cups"
RDEPEND="${DEPEND}"

S=${WORKDIR}

src_unpack() {
	rpm_unpack ${A}
}

src_prepare() {
	default

	# change initscript name from cups to cupsd (for openrc);  what about systemd?
	# opt/brother/PTouch/ql700/cupswrapper
	cd "${S}"/opt/brother/PTouch/ql700/cupswrapper
	mv cupswrapperql700 cupswrapperql700.bak
	#/bin/sed 's/\/etc\/init.d\/cups\ restart/\/etc\/init.d\/cupsd\ restart/g' cupswrapperql700.bak > cupswrapperql700 || die "sed failed!"
	/bin/sed 's/\/etc\/init.d\/cups\ /\/etc\/init.d\/cupsd\ /g' cupswrapperql700.bak > cupswrapperql700 || die "sed failed!"

	# Copy either x86_32 or x86_64 binaries
	# copy either 32-bit or 64-bit binaries from i686 or x86_64 to lpd/

	# ABI_x86_64
	# opt/brother/PTouch/ql700/lpd
	cd "${S}"/opt/brother/PTouch/ql700/lpd
	mv x86_64/* .; rmdir x86_64

	# ABI_x86_32
	# cd "${S}"/opt/brother/PTouch/ql700/lpd
	# mv i686/* .; rmdir i686
}

src_install() {
	has_multilib_profile && ABI=x86

	insinto  opt/brother/PTouch/ql700
	doins -r opt/brother/PTouch/ql700/*

	# Copy 2 binaries (either 32-bit or 64-bit) from lpd to /usr/bin 
	dobin opt/brother/PTouch/ql700/lpd/brprintconfpt1_ql700
	dobin opt/brother/PTouch/ql700/lpd/brpapertoollpr_ql700

	# Fix permissions and ownership 
	fowners root:lp /opt/brother/PTouch/ql700/inf
	fperms  775     /opt/brother/PTouch/ql700/inf
	fowners root:lp /opt/brother/PTouch/ql700/inf/brql700rc
	fperms  664     /opt/brother/PTouch/ql700/inf/brql700rc
	fperms 755 /opt/brother/PTouch/ql700/cupswrapper/brother_lpdwrapper_ql700
	fperms 755 /opt/brother/PTouch/ql700/cupswrapper/cupswrapperql700
	fperms 755 /opt/brother/PTouch/ql700/cupswrapper/cupswrapperql700.bak

	# Create some symlinks
	dosym ../../../../../opt/brother/PTouch/ql700/cupswrapper/brother_lpdwrapper_ql700        usr/lib64/cups/filter/brother_lpdwrapper_ql700
	dosym ../../../../../opt/brother/PTouch/ql700/cupswrapper/brother_lpdwrapper_ql700        usr/libexec/cups/filter/brother_lpdwrapper_ql700
	dosym ../../../../../../opt/brother/PTouch/ql700/cupswrapper/brother_ql700_printer_en.ppd usr/share/cups/model/Brother/brother_ql700_printer_en.ppd
}

pkg_postinst() {
	# create udev rule
	elog "Please create a persistent udev rule if such as this:"
	elog "# cat /etc/udev/rules.d/42-brother-ql700.rules"
	elog "SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"04f9\", ATTRS{idProduct}==\"2042\", ATTRS{serial}==\"SERIALNUMBER\", MODE=\"0664\", GROUP=\"lp\",  SYMLINK+=\"usb/lp0_SERIALNUMBER\""
	elog "where the serial number is that reported by \"lpinfo -v |grep \"direct usb://Brother/QL-700\""
	elog ""
	elog "You must first turn on or wake up the Brother QL-700 label printer"

	# lpadmin -p QL700 -E -v  usb://Brother/QL-700?serial=XXXXXXXXXXXX  -P /usr/share/cups/model/Brother/brother_ql700_printer_en.ppd
	elog "Please create the cups printer queue for your label printer like follows:"
	elog "lpadmin -p DESTINATION -E -v URI  -P /usr/share/cups/model/Brother/brother_ql700_printer_en.ppd"
	elog "where DESTINATION will be the name of the printer destination (e.g. QL700) and"
	elog "URI is that reported by \"lpinfo -v\" (e.g.  usb://Brother/QL-700?serial=XXXXXXXXXXXX)"
	elog ""
	elog "You may enable debugging by setting DEBUG=1 and/or  LPD_DEBUG=1"
	elog "in the perl script \"/opt/brother/PTouch/ql700/cupswrapper/brother_lpdwrapper_ql700\""
	elog "at lines 34 and 37 respectively"
	elog ""
	elog "Brother\'s website says: \"Connecting more than one machine with the same model number is not supported.\""
}
