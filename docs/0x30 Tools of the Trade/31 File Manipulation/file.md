---
title: "Parsing File Metadata"
---

<h1>Parsing File Metadata</h1>

## The `file` Utility

On Unix-like systems (e.g. macOS, Linux, BSD), the `file` utility can determine file types by examining their metadata:

```sh
(iso.venv) analyst@lab_vm iso.venv % file statem~1.doc 
statem~1.doc: Microsoft Word 2007+
(iso.venv) analyst@lab_vm iso.venv % file statem~1.lnk 
statem~1.lnk: MS Windows shortcut, Item id list present, Points to a file or directory, Has command line arguments, Icon number=0, Archive, ctime=Fri Apr  9 19:50:46 2021, mtime=Wed Oct  5 04:38:35 2022, atime=Fri Apr  9 19:50:46 2021, length=452608, window=hidenormalshowminimized
(iso.venv) analyst@lab_vm iso.venv % file install.ps
install.ps: ASCII text, with very long lines (12834), with CRLF line terminators
```

This is especially useful when trying to identify files for which the original filenames have been lost, or whose filenames have been intentionally obfuscated.

_Windows users can use a [Windows-specific port](https://github.com/julian-r/file-windows/releases/) of the `file` utility, or use the [Cygwin](https://www.cygwin.com/) bundle, in which the `file` utility is bundled._