#!/usr/bin/env node
// 
// # Watch JS
//
// Watch is a simple KDFramework friendly watch file. It watches a directory
// for changes, collects all the files that change over the course of the watch
// and then exits with a response of the changed files.
//
var fs = require('fs')
  , path = require('path')

if (process.argv.length <= 2) throw new Error('Directory is required')

var changedFiles  = []
  , watcher       = null
  , targetAppDir  = process.argv[2]
  , watchTimeout  = 30000
  , manifest      = JSON.parse(fs.readFileSync(targetAppDir +'/manifest.json'))
  , watchedFiles  = []


findFiles = function(object) {
  if (object instanceof Array) {
    for (var i=0; i < object.length; i++) {
      watchedFiles.push(path.normalize(object[i]))
    }
  } else {
    for (key in object) {
      findFiles(object[key])
    }
  }
}
findFiles(manifest.source)

watcher = fs.watch(targetAppDir, function(event, filename) {
  // Ignore non-change events.
  if (event != 'change') return
  
  // Ignore non-watched files.
  if (watchedFiles.indexOf(filename) == -1) return
  if (changedFiles.indexOf(filename) >= 0) return
  
  changedFiles.push(filename)
})

// Lastly, add a timeout so we can end this.
setTimeout(function() {
  watcher.close()
  console.log(changedFiles.join(','))
}, watchTimeout)
