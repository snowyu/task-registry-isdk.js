## task-registry-isdk [![npm](https://img.shields.io/npm/v/task-registry-isdk.svg)](https://npmjs.org/package/task-registry-isdk)

[![Build Status](https://img.shields.io/travis/snowyu/task-registry-isdk.js/master.svg)](http://travis-ci.org/snowyu/task-registry-isdk.js)
[![Code Climate](https://codeclimate.com/github/snowyu/task-registry-isdk.js/badges/gpa.svg)](https://codeclimate.com/github/snowyu/task-registry-isdk.js)
[![Test Coverage](https://codeclimate.com/github/snowyu/task-registry-isdk.js/badges/coverage.svg)](https://codeclimate.com/github/snowyu/task-registry-isdk.js/coverage)
[![downloads](https://img.shields.io/npm/dm/task-registry-isdk.svg)](https://npmjs.org/package/task-registry-isdk)
[![license](https://img.shields.io/npm/l/task-registry-isdk.svg)](https://npmjs.org/package/task-registry-isdk)

ISDK Task is a genernal buiding task.
It takes a `cwd` directory and process it.
The `src` is the file patterns to filter files.
It outputs to the `dest` directory at last.
It's used via isdk internally.


* load file configuraions
* init default options of tasks
* process files

## Usage

```coffee
Task = require 'task-registry'
require 'task-registry-isdk'

isdk = Task 'isdk'

isdk.executeSync cwd: '.', src:'*.md', dest: './public'

```

## API


## TODO


## License

MIT
