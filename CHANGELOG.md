# 0.1.4 / 

- Added Ctrl-Enter FullWindow support.
- [#9](https://github.com/leeolayvar/appaid.kdapp/issues/9):
  Removed Header from the AppAid Bar
- [#11](https://github.com/leeolayvar/appaid.kdapp/issues/11):
  Features that require a sub-app to be loaded are now hidden when an app
  is not loaded.

# 0.1.3 / 2013-09-03

- [#5](https://github.com/leeolayvar/appaid.kdapp/issues/5):
  A clear app button has been added.
- [#6](https://github.com/leeolayvar/appaid.kdapp/issues/6):
  Compile failures now give sane responses no matter what the exit code.
- [Related #7](https://github.com/leeolayvar/appaid.kdapp/issues/7):
  Added better notifications for the whole compile process.

# 0.1.2 / 2013-09-02

- Corrected installation steps in readme.
- Added a more helpful default preview message.

# 0.1.1-1 / 2013-09-02

- Fixed a couple missing variables that drunk-lee introduced. It's mostly
  just a patch until [this](/leeolayvar/appaid.kdapp/issues/2) is implemented.

# 0.1.1 / 2013-09-02

- KDC returns an `ExitStatus: 34` if it is used to compile an application with
  missing source definitions. This will actually be a pretty common error due
  to the fact that users will try and compile existing apps without the source.

# 0.1.0 / 2013-09-01

- First release. Basic feature set including manual & auto compile, refreshing,
  and app embedding.
