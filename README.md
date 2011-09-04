# iOS development overlay for Gentoo
## To get started:

1. Download [Xcode](http://developer.apple.com/xcode/) from Apple.
2. Download this overlay via git, or use a tarball from the Downloads link above:
   ```git clone git://github.com/gh2o/ios-overlay.git```
3. Add the overlay to your /etc/make.conf:
   ```PORTDIR_OVERLAY="/path/to/overlay"```
4. Emerge!
   ```emerge ios-toolchain```

## And now let's build something!

### grapes.m:
```
#include <Foundation/Foundation.h>
#include <stdio.h>

int main ()
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];   
	NSLog (@"Go eat some grapes.");
	[pool release];
	return 0;
}
```

### commands:
```
$ arm-apple-darwin10-gcc grapes.m -o grapes -lobjc -framework Foundation
$ scp grapes mobile@ipod:/tmp/
mobile@ipod's password:
$ ssh mobile@ipod /tmp/grapes
mobile@ipod's password:
2011-09-04 00:00:00.000 grapes[...] Go eat some grapes.
$
```