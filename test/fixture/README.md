---
tasks:
  <: #inherits the parent's tasks if any
    - Echo
src:
  - "**/*.md"
  - "!**/.*"
  - "!./public"
---
this is the test folder.

the `README.md` is the configuration of this folder.