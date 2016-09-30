# Allegro 4.4.2 build for OSX

This is a build of Allegro 4.4.2 for Mac OS X. It's quite difficult to build this version of the library on modern systems due to the outdated dependencies it has. These instructions require the use of the OSX 10.4 SDK.

All examples that actually draw a window (such as the `grabber` or `miditest`, etc) will not work properly on retina displays. If you know how to fix this, please feel free to let me know. Presumably, this can be fixed by bundling them as `.app` directories, which allows Mac OS X to run them with double pixels.

Extraneous files have been removed, as well as the demos. The examples are still there, though. The main reason for the existence of this repository is to have a premade build available for Mac OS X.

## Compiling instructions

For those interested in building the library, here's a quick guide. Note that this repository only contains a *build*, and not the Allegro source files.

### OSX Yosemite (10.10)

Allegro 4 is quite old and requires a number of deprecated header files that are long gone from the Xcode SDKs. To successfully compile the library, you'll need the following:

* Copy of the [Allegro 4.4.2 source](https://www.allegro.cc/files/?v=4.4) (download `allegro-4.4.2.zip`)
* Some dependencies (flac, libogg, libvorbis, opus, physfs, cmake, freetype, libpng, openssl, opusfile, theora; all of these are easily installed with [Homebrew](http://brew.sh/index.html))
* The Mac OS X 10.4 universal SDK

For the SDK, you need to download the Xcode 3.1 installer (named `xcode31_2199_developerdvd.dmg`) which is available on the [Apple Developer site](https://developer.apple.com/download/more/). You need to register an account to get the download, which is listed as *Xcode 3.1 Developer Tools*.

Open the developer DVD image, then install the *MacOSX10.4.Universal.pkg* file in the *Packages* directory, which will place the SDK in `/SDKs/MacOSX10.4u.sdk`. You can delete the Xcode 3.1 image now, since we only need this one file.

Now browse to your unzipped Allegro 4.4.2 source, make a directory called `build` and go there, and then type the following:

    export MACOSX_DEPLOYMENT_TARGET=10.4
    export CFLAGS=-m32
    cmake -DCMAKE_OSX_SYSROOT=/SDKs/MacOSX10.4u.sdk -DCMAKE_OSX_DEPLOYMENT_TARGET=10.4 ..

Note that we're forcing a 32-bit build, which is necessary to use the 10.4 SDK. If all goes well, CMake will have found and configured everything successfully. If there are any missing dependencies, it will tell you here. Non-critical warnings can be ignored.

Then, just type `make`. This should successfully build the framework and the associated binaries.

#### Dylib linking

Unfortunately, there's a problem that I haven't been able to resolve yet: building in this way causes binaries (such as the very useful `dat` utility) to look for the `liballeg` dylib in the absolute path where it ended up after the build process finished.

To fix this, I've added a script `fixrpath.bash` that relinks the dylib to a relative path (specifically, `../lib`). This has already been done in this build, but it's useful in case you want to make your own build. Of course, it would be much nicer to not have to deal with this problem at all, by fixing it in the Allegro CMake file, but I don't know how to do that.

To explain how the `fixrpath.bash` script works, it's basically modifying the binary to look for the library elsewhere. In this example I'll make the `dat` utility look for `liballeg.4.4.dylib` in the `../lib/` directory, rather than the full path of my build.

    # set relative path to the ../lib directory
    install_name_tool -add_rpath @loader_path/../lib/ dat
    # change dylib load from an absolute path to a relative path
    install_name_tool -change /Users/msikma/test/allegro/build/lib/liballeg.4.4.dylib @rpath/liballeg.4.4.dylib dat

Note that the absolute path I give is unique to my compilation setup, and will be different for you. To find the exact path string to replace, use `otool -lv dat`. After this, the `dat` utility should work as long as the `liballeg.4.4.dylib` file is in the `../lib` directory.

### OSX El Capitan (10.11) and up

I'm not sure if the instructions work for El Capitan 10.11, but I know they don't work for Sierra 10.12. The following error is displayed:

    ...
    [ 24%] Building C object CMakeFiles/allegro.dir/src/unix/ufile.c.o
    [ 25%] Building C object CMakeFiles/allegro.dir/src/unix/utimer.c.o
    [ 25%] Building C object CMakeFiles/allegro.dir/src/unix/uptimer.c.o
    [ 25%] Building C object CMakeFiles/allegro.dir/src/unix/usystem.c.o
    [ 25%] Building C object CMakeFiles/allegro.dir/src/unix/uthreads.c.o
    [ 25%] Linking C shared library lib/liballeg.dylib
    ld: in '/SDKs/MacOSX10.4u.sdk/System/Library/Frameworks//Accelerate.framework/Versions/A/Accelerate', malformed mach-o, symbol table not in __LINKEDIT
    clang: error: linker command failed with exit code 1 (use -v to see invocation)
    make[2]: *** [lib/liballeg.4.4.2.dylib] Error 1
    make[1]: *** [CMakeFiles/allegro.dir/all] Error 2
    make: *** [all] Error 2

* Compiler: `Apple LLVM version 8.0.0 (clang-800.0.38)`
* Linker: `@(#)PROGRAM:ld  PROJECT:ld64-274.1`.

This may be related to [this question on Stack Overflow](http://stackoverflow.com/questions/39381754/malformed-mach-o-image-symbol-table-underruns-linkedit) but I'm not sure. I haven't spent any time getting it to work.

## Feedback

If you have any questions, or things to contribute, [please let me know!](https://twitter.com/michielsikma)

## Copyright

© 2016, Michiel Sikma. MIT license. [Allegro 4.4.2 is giftware licensed.](http://liballeg.org/license.html)