![](https://i.imgur.com/x6YjwNe.png)

go·reader is a minimalistic comic & manga reader which provides a seamless and buttery smooth reading experience. With [go·reader's infinite scroll](https://i.imgur.com/Xdb2Fgc.mp4), read through hundreds (or thousands) of pages in a single sitting-- without any loading screens or having to load the next file! And if you don't finish the 40 volumes of *Berserk* in a single sitting, go·reader will resume where you left off when you open the app again.

go·reader is powered by Godot game engine. In fact, that's why it's called go·reader. go(dot)reader. Heh.

--------------------------------------

## Primary Features

- Infinite scroll for seamless reading
- Support for the major comic/ manga file types-- CBZ, CBR, ZIP, RAR, etc.
- Support for comic/ manga in loose image form-- PNG, JPEG, GIF, etc
- The ability to jump from page 0 to page 420 of *Berserk* instantly
- An easy-to-use interface that allows you to focus on the comic or manga

------------------------

## Quick Start

1. Grab the latest version from the [releases page](https://github.com/Sirosky/go-reader/releases).
2. Unzip it into the directory of your choice.
3. Right click anywhere to import the folder containing the eBooks (CBZ, CBR, ZIP etc). A good idea would be to keep all the chapters of a series inside a single folder, and select that folder for importing. Due to limitations of Godot game engine, go·reader can only read a series after you import it. If you have issues with this step, take a look at the full guide below.
4. Right click or press L to load the series you just imported.
5. Start reading!

---------------------------

## Screenshots

![](https://i.imgur.com/Qh40uVO.png)

![](https://i.imgur.com/55xudZJ.png)

------------------------

## Philosophy

go·reader's sole purpose is to deliver a smooth reading experience-- that is to do one thing, and do it well. Thus it is not intended to be a replacement for the likes of Calibre or YACReader. I came up with the idea of go·reader after being mildly inconvenienced by how CDisplayEx handled loading-- it took a few extra seconds more than I would've liked. So I spent dozens of hours programming go·reader. Yes, I'm that petty.

-----------

## Full Guide

### Get Started

![](https://i.imgur.com/GCGs5BH.png)

When you first launch the app, this menu should appear after the initial welcome popup.

1. **load from library**- select a directory, and it'll load the items you've imported into that directory.
2. **import ebook**- if your comics or manga are in CBZ, CBR, RAR, ZIP, or some other zipped-up format, this is the option to use. The app will prompt you for the *directory* containing the eBooks. Enter that directory. Then the app will prompt you for where in the Library you wish to import the eBooks. Select a folder and the import process will begin. go·reader will automatically bulk import all the eBooks located in the source directory.
3. **import to library**- use this option if your comic is in loose JPG, PNG, GIF etc. Essentially this just means a bunch of images inside a folder. Otherwise, the process is the same as the import ebook command
4. **change settings**- allows you to change the basic settings of go·reader. There aren't many options for now, but I'll work more in with due time.
5. **about**- just some basic information regarding go·reader. Also has the keyboard shortcuts.

### Context Menu

![](https://i.imgur.com/VEh6nUm.png)

This is the context menu. You can bring it up any time by simply right clicking. Most of the options here are self-explanatory or covered above. So we'll just discuss the new options present.

1. **Open Library in Windows**- this will open the folder where the Library is located in Windows Explorer. Useful for manually transferring files or managing your imported files.
2. **Jump to page**- this allows you to jump to a specific page that you have loaded. Takes any value between 0 to the max page count.

### Manually Importing 

In the scenario where the import fails for whatever reason, you can still manually import your files. The process is very straightforward.

1. Right click in go·reader and select "Open Library in Windows" to open the library folder in Windows Explorer.
2. Copy the folder containing your eBook or loose images into the library folder.
3. If you copied over eBooks, use a program such as 7zip and extract the contents.
4. You should now be able to load your comic or manga with go·reader!

### **FAQ**

1. **Can I change the location of the library?** Unfortunately not. This is a limitation set by Godot. Similarly comics and manga must first be imported before they can be read.
2. **Is there/ will there be support for double-page mode?** No. There are several reasons for this: 1) I need a looooong break from working on the infinite scroll code, 2) CDisplayEx supports double-page mode and does a pretty good job of it already, and 3) double page mode isn't as suitable for infinite scroll.
3. **Can I use this on Mac or Linux?** go·reader is designed for Windows only. However you are free to compile the project using Godot on your Mac or Linux device. It *should* work for the most part. However, you will likely need to import manually.
4. **Is there/ will there be support for PDFs?** No. PDFs are a completely different beast compared to CBZs/ CBRs/ other typical comic and manga formats. But if anyone knows of a portable, command line software that can extract PDF pages as images and also allows for redistribution, do let me know.

----------

## Credit

1. A big thanks to [willnationsdev](https://gist.github.com/willnationsdev) for putting up with my incessant GDScript questions during the odd hours of the day (and night).
2. Apple for serving as my valued beta tester and guinea pig.
3. The creators and contributors of [Godot game engine](https://godotengine.org/) for creating this superb platform.
4. The creators and contributors [7-zip](https://www.7-zip.org/), which does all the heavy lifting for go·reader's eBook importation code.
