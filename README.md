dospad
======

dosbox port for iOS, aka iDOS, based on dosbox v0.74-3 and SDL1.2.

This is an all-in-one project, so the build process is just one simple click in xcode.

The Documents folder within app sandbox is automatically mounted as disk c. You can access this folder either on "Files app -> On My iPad/iPhone".
On macOS catalina, you can find it in "Finder->Locations->Your iDevice->Files" tab.

## iDOS Package

You can launch iDOS by tapping on an *.idos package.
The package is actually a folder, and will be mounted as disk c.
The package should include a dospad.cfg with all dosbox settings.

If the package contains a `cover.png` or `scrnshot.png`, it will be used to generate thumbnails for Files app.
