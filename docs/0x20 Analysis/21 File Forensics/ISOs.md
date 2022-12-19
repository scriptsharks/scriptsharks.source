---
title: "ISO Files"
---

<h1>ISO Files</h1>

Files ending with `.iso` are uncompressed archives designed to represent physical, write-only storage media, such as CD-R and DVD-R discs. ISO files contain not only the full, uncompressed content of every file in the archive, but also the exact structure of the data and additional filesystem information. This enables the creation of "perfect" copies when burning the ISO to a physical disc. For more information, check out the [FileFormat documentation for the ISO filetype](https://docs.fileformat.com/compression/iso/).

## Dynamic Analysis

Most modern OSes (Linux, macOS, Windows) include bundled methods for accessing the contents of ISO files. In these OSes, double-clicking the file will mount it as a virtual disc drive, as if it were a physical disc. In addition, many archive management utilities (such as [7zip](https://www.7-zip.org/download.html)) allow users to extract the contents of an ISO file in the same manner as other archive types, such as `.zip`.

While convenient, these methods come with risks. For example, if a Windows system is configured to automatically launch installers from CDs and DVDs, then mounting an ISO as a virtual drive could trigger the execution of malware.

Opening an ISO with 7zip and similar utilities is a little safer, as they simply extract the archived files, rather than treating them as a virtual drive. However, there may still be risks.

In either case, as with all malware, ISO files should be opened in a properly-isolated VM.

## Static Analysis

### Via PyCDLib
It is also possible to examine ISO files interactively, using Python (or your language of choice). To demonstrate, we'll start with the `pycdlib` [library](https://github.com/clalancette/pycdlib). As this is not part of the [standard library](https://docs.python.org/3/library/), you'll need to install it before it can be used:

```sh
(iso.venv) analyst@lab_vm iso.venv % pip install pycdlib
Collecting pycdlib
[...]
Successfully installed pycdlib-1.13.0
```

With `pycdlib` installed, we can now explore a malware ISO file. First, we'll need to mount the ISO:

```python
>>> import pycdlib
>>> iso = pycdlib.PyCdlib()
>>> iso.open("documents.iso")
```

With the ISO open, we can list the contents of the root directory:

```python
>>> for child in iso.list_children(iso_path="/"):
...     print(child.file_identifier())
... 
b'.'
b'..'
b'DOCS'
b'STATEM~1.LNK;1'
```

We can also list contents of subdirectories in the same manner:

```python
>>> for child in iso.list_children(iso_path="/DOCS/"):
...     print(child.file_identifier())
... 
b'.'
b'..'
b'INSTALL.PS1;1'
b'STATEM~1.DOC;1'
```

From our exploration, we can see the following directory structure:

* `/`
    * `/STATEM~1.LNK`
    * `/DOCS`
        * `/DOCS/INSTALL.PS1`
        * `/DOCS/STATEM~1.DOC`

We can also obtain a directory structure via the `iso.walk` method:

```python
>>> for dname, dlist, flist in iso.walk(iso_path="/"):
...     print(f"{dname}: {dlist} {flist}")
... 
/: ['DOCS'] ['STATEM~1.LNK;1']
/DOCS: [] ['STATEM~1.DOC;1', 'INSTALL.PS1;1']
```

We can gather information about specific files by their ISO path:

```python
>>> record = iso.get_record(iso_path="/DOCS/INSTALL.PS1;1")
>>> record.is_file()
True
>>> record.is_dir()
False
>>> record.get_data_length()
12836
```

When done working with the ISO, be sure to close it:

```python
>>> iso.close()
```

### Via FS.Archive

We can also use the `fs.archive` [library](/////), another non-standard Python extension, which wraps around `pycdlib` to provide a simpler interface. To start, we'll need to install the package:

```sh
(iso.venv) analyst@lab_vm iso.venv % pip install fs.archive
Collecting fs.archive
[...]
Successfully installed appdirs-1.4.4 fs-2.4.16 fs.archive-0.7.3
```

With the utility installed, we can open the ISO:

```python
>>> from fs import open_fs
>>> from fs.archive import open_archive
>>> root = open_fs("./") # Path where the ISO is stored.
>>> archive = open_archive(root, "documents.iso")
>>> archive.isempty(path="/")
False
```

We can now explore the contents of the ISO:

```python
>>> for path, dirs, files in archive.walk():
...     print(f"{path}:\n\tDirs: {dirs}\n\tFiles: {files}")
... 
/:
        Dirs: [<dir 'docs'>]
        Files: [<file 'statem~1.lnk'>]
/docs:
        Dirs: []
        Files: [<file 'install.ps'>, <file 'statem~1.doc'>]
```

We can now extract the contained files:

```python
>>> def save(path):
...     fname = path.split("/")[-1]
...     f = archive.open(path=path)
...     contents = f.buffer.readall()
...     with open(fname, 'wb') as outfile:
...         outfile.write(contents)
...     f.close()
... 
>>> for path in [
...     "/statem~1.lnk",
...     "/docs/install.ps",
...     "/docs/statem~1.doc"
... ]:
...     save(path)
```

After executing this code, we should have three new files in our working directory:

```sh
(iso.venv) analyst@lab_vm iso.venv % ls -l
total 11656
drwxr-xr-x  8 analyst  staff      256 Dec 19 15:28 .
drwxr-xr-x@ 5 analyst  staff      160 Dec 19 15:28 ..
-rw-r--r--@ 1 analyst  staff  1245184 Dec 19 13:40 documents.iso
-rw-r--r--  1 analyst  staff    12836 Dec 19 15:25 install.ps
-rw-r--r--@ 1 analyst  staff  1992525 Dec 13 16:01 statement.htm
-rw-r--r--  1 analyst  staff     5467 Dec 19 15:25 statem~1.doc
-rw-r--r--  1 analyst  staff     2357 Dec 19 15:25 statem~1.lnk
-rw-r--r--  1 analyst  staff  2698674 Dec 13 15:45 suspicious.eml
```

The files are cleanly extracted, ready for further analysis!

### An Important Note

The demonstrated methods do not preserve the files' original names. This is, in part, due to the way filenames are saved in ISO files and parsed by the referenced Python libraries. This does not directly represent what is observed when the ISO is opened on a host, but this could be seen as a benefit; malware distributed by ISO often employs tricks that are path-dependent, such as the LNK file in the sample, which calls the PS1 file by name. If the name is changed (such as `statement.doc.lnk` being compressed to `statem~1.lnk`), this can break the malware's functionality.

To preserve filenames, you may want to use the dynamic methods, such as mounting the image, or extracting it with 7zip.