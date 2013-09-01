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
  , watchers      = []
  , targetAppDir  = process.argv[2]
  , watchThrottle = 3000
  , pastThrottle  = false
  , watchTimeout  = 30000
  , timeoutId     = null
  , manifest      = JSON.parse(fs.readFileSync(targetAppDir +'/manifest.json'))
  , watchedFiles  = []


findFiles = function(object) {
  if (object instanceof Array) {
    object.forEach(function(file) {
      watchedFiles.push(path.resolve(targetAppDir, file))
    })
  } else {
    for (key in object) {
      findFiles(object[key])
    }
  }
}
findFiles(manifest.source)

watchedFiles.forEach(function(watchFile) {
  watchers.push(fs.watch(watchFile, function(event, filename) {
    // Ignore non-change events.
    // Note that we allow "rename" for Vim support, which is caused by
    // the swapping.. i assume.
    if (event != 'change' && event != 'rename') return
    
    // Ignore non-watched files.
    //if (watchedFiles.indexOf(filename) == -1) return
    //if (changedFiles.indexOf(filename) >= 0) return
    
    changedFiles.push(filename)

    if (pastThrottle) {
      clearTimeout(timeoutId)
      watchers.forEach(function(watcher) {
        watcher.close()
      })
      console.log(changedFiles.join(','))
    }
  }))
})

// Set up a throttle timeout, which ensures we don't end too fast..
// in the future we may handle this in the client.
setTimeout(function() {
  pastThrottle = true
}, watchThrottle)

// Lastly, add a timeout so we can end this.
timeoutId = setTimeout(function() {
  watchers.forEach(function(watcher) {
    watcher.close()
  })
  console.log(changedFiles.join(','))
}, watchTimeout)


