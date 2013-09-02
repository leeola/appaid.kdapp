
# AppAid

AppAid is a [Koding](https://koding.com) App designed to help you develop your
app faster.

It does this by embedding another app into itself, and watching your file
system for changes *(if you enable auto)*.

# Installation

Currently you need to clone this library. There will be a video on installation,
but for now follow the steps below:
and then click Refresh in your Develop Tab. After this, make sure to compile
it before you run it :)

1. Clone this repo with
  `git clone https://github.com/leeolayvar/appaid.kdapp.git ~/Applications/appaid.kdapp`
2. Refresh your App List
3. In the upper right of the App Icon, there should be a compile button,
  click it.
4. Open the app!

# Usage

Select your app from the app list, click **Load App**, and your app will load
into the app region.

## Manual Compiling

To compile and reload your app manually, simply click **Compile and Preview**.

## Automatic Compiling

Simply toggle **Auto** on. A process will launch on the server, and monitor
all of the files you have specified in your apps manifest.

# Future

## v0.1.0

0.1.0 is what you see here now. The focus will be easy compiling, auto
compiling, and app usage. I may also include multi-VM workflow soon as well.

## v0.2.0

0.2.0 will focus on unit testing.

By loading a unit testing framework along with AppAid, we will be able to
provide automatic testing upon each compile, automatic or manual. This will
allow for rapid development without feature regression.

If you're passionate on the subject please [add to the discussion][1]! The
specific unit testing libraries and interfaces are subject to change, so you
can shape it :)



[1]: https://github.com/leeolayvar/appaid.kdapp/issues/1
