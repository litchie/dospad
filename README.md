nDOS
====
nDOS is a DOSBox port for iOS and iPadOS, allowing you to run old MS-DOS games and programs. nDOS is forked from the original iDOS/DOSPad project but updated to use the latest code from the DOSBox SVN source tree. It also contains additional patches and customizations. Please see the [Acknowledgements](#acknowledgements) section

Purpose
====
I'm a retro computing enthusiast. I especially enjoy gaming from the MS-DOS and early Microsoft Windows era. I'm also a fan of Apple products, especially the iPad. Playing old DOS/Windows games on a touchscreen device like an iPad brings old memories back to life using modern gear. 

I also wanted to take on a coding project that would be fun while learning about the Apple SDKs and developing in the iOS ecosystem (even if the project is using an older Objective-C base).

Why is it called nDOS? Because I lack imagination and couldn't think of a better name when I decided to fork this from iDOS. 😆

Development
====
I'm a full time Dad and professional IT Architect. I am maintaining this project as much as I can when I have spare time, but don't always have a lot of time to commit. Feel free to submit issues or even pull requests. I try to keep the code merged and updated with the latest DOSBox SVN source tree. 

I am exploring moving this code to a different DOSBox port, such as DOSBox-X, so you can better run Windows 95/98 games. I haven't spent a ton of time yet reviewing the Objective-C overlay and how much work this might be. 

Additionally, I would like to transition much of this to Swift overlay for long-term maintainability. 

**NOTE**: Most of my development testing is taking place on an iPad Pro (4th Gen). While there are build profiles and support for iPhone, I have not conducted extensive testing on iPhone so it may or may not work correctly. The original iDOS project contained support for iPhone, but with the patching and updates I have completed, that platform needs testing.

Patches/Customizations
====
* Latest DOSBox SVN source revisions merged from the community
* Updates to the code to utilize non-deprecated functions and methods. Eliminates deprecated iOS warnings for the original dospad code. Does not fix DOSBox source warnings.
* UI tweaks for improved experience with some games (e.g. Civilization 1).
* IMGMAKE patch allowing creation of floppy and harddisk images within DosBox. This is a convenience feature for creating images to organize software packages or install other retro operating systems under DOSBox (e.g. DOS 6.22, Windows 2.03). Reference: [imgmake](https://www.vogons.org/viewtopic.php?t=19349)
* Patched to support max memory of 383MB. This can be used for running Win9x (although not tested)
* Apple Pencil gesture support
* Additional DOS support commands (such as XCOPY, DOSIDLE, MEM etc). See branch `vfile-additions` for more information.

Acknowledgements
====
Thanks to the @dosbox team for creating a great platform to relive DOS gaming memories. More information can be found at the [DOSBox Project Page](https://www.dosbox.com/).

Thanks to @litchiedev for building a version of DOSBox that works on iOS/iPadOS. 


