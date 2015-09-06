# run npm install programmly
npmInstall        = require 'npm-command/lib/install'
changeCase        = require 'change-case'
isObject          = require 'util-ex/lib/is/type/object'
isArray           = require 'util-ex/lib/is/type/array'
Resource          = require 'isdk-resource'
Task              = require 'task-registry'
#register the tasks execution to the task-registry factory.
require 'task-registry-isdk-tasks'

register          = Task.register
aliases           = Task.aliases
defineProperties  = Task.defineProperties
tasks             = Task 'Tasks'

module.exports    = class ISDKTask
  register ISDKTask
  aliases ISDKTask, 'isdk'

  defineProperties @,
    cwd: # current working directory.
      type: 'String'
      value: '.'
    src: # it should be a string or array of string.
      type: ['String', 'Array']
    dest:
      type: 'String'
      value: './public'
    autoInstall:
      type: 'Boolean'

  initMissedTasks = (aTasks)->
    vPkgNames = aTasks.map (i)->
      result = i.name.split('/').join('-')
      result = changeCase.paramCase result
      if result.indexOf('task-registry') is -1
        result = 'task-registry-'+result
      result

    npmInstall vPkgNames, save:true, (err, data)->
      return console.error err if err
      aTasks.forEach (t, i)->
        try
          require vPkgNames[i]
          Task i.name, i.options
  initTasks: (aInitConfig, aOptions)->
    vMissedTasks = []
    if isObject aInitConfig
      for name, opts of aInitConfig
        task = Task(name, opts)
        vMissedTasks.push name:name, options:opts unless task
      if aOptions.autoInstall and vMissedTasks.length
        initMissedTasks vMissedTasks
    return
  processFileSync: (aFile)->
    if aFile and aFile.tasks
      tasks.executeSync aFile
    return
  processSync: (aFiles)-> #process a files in a folder
    if isArray aFiles
      for file in aFiles
        file.loadSync(read:true) unless file.loaded()
        if file.isDirectory()
          @processSync(file.contents)
        else
          @processFileSync(file)
  _executeSync: (aOptions)->
    root = Resource aOptions.cwd, aOptions
    root.loadSync read:true, recursive:true
    @initTasks root['initConfig'], aOptions # the initialization configuration of tasks.
    @processSync root.contents
