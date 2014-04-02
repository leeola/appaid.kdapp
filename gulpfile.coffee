#
# # Gulp File
#
# This gulpfile is used to compile the KDC App.
#
# For build instructions see the README
#
gulp       = require 'gulp'
browserify = require 'gulp-browserify'
rename     = require 'gulp-rename'
sass       = require 'gulp-sass'


paths =
  bundle: 'main.coffee'
  sass: [
    'styles/*.scss'
  ]


gulp.task 'bundle', ->
  gulp.src paths.bundle, read: false
    .pipe browserify
      builtins: false
      transform: ['coffeeify']
      extensions: ['.coffee']
    .pipe rename 'index.js'
    .pipe gulp.dest './'

gulp.task 'sass', ->
  gulp.src paths.sass
    .pipe sass()
    .pipe gulp.dest 'resources'


gulp.task 'build',   ['bundle', 'sass']
gulp.task 'default', ['build']
