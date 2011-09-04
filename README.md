# iOS development overlay for Gentoo
To get started:
1. Download [Xcode](http://developer.apple.com/xcode/) from Apple.
2. Download this overlay via git:
   ```git clone git://github.com/gh2o/ios-overlay.git```
   Or use a tarball from the Downloads link above.
3. Add the overlay to your /etc/make.conf:
   ```PORTDIR_OVERLAY="/path/to/overlay"```
4. Emerge!
   ```emerge ios-toolchain```
