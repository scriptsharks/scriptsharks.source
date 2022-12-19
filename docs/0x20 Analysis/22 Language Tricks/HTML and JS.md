---
title: "HTML and JavaScript"
---

<h1>HTML and JavaScript</h1>

## Embedded File Downloads

### Overview

HTML droppers often abuse **embedded file downloads** to imitate downloading a file from the internet. With this technique, arbitrary files can be embedded within an HTML document, then extracted via web browsers' built-in "download" functionality. This looks nigh-indistinguishable from typical downloads.

There are a few benefits to this technique:

* It bypasses web content filters.
    * These filters block access to malicious sites, including malware-distribution sites.
    * Users who are aware of these filters expect to be protected from malicious files.
    * Embedded downloads can abuse this trust, reducing suspicion of embedded files.
* It does not require a network connection.
    * Embedded files are fully contained within an HTML document.
    * If the user has the HTML document, they can download the embedded file offline.
* It can be disguised with ease.
    * The HTML dropper can imitate legitimate websites, web content filters, etc.
    * This makes them especially useful when distributing malware via phishing emails.

### Examples

Embedded files can appear as a simple HTML hyperlink tag:

```html
<a href="data:application/octet-stream;base64,AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
    target="_self" download="documents.iso">
    Download this file
</a>
```

In this instance, the `documents.iso` file is embedded as a base64-encoded link in the `href` attribute of the hyperlink. When the user clicks the "Download this file" link, the download is initiated.

Rather than depending on users to click hyperlinks, embedded files can also be served via JavaScript, set to download as soon as the page has loaded:

```html
<html>
    <head>
        <script>
            const filename = "documents.iso";
            const contentBase64 = (
                 "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
                +"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
                +"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
                // [and so on]
            );
            function trigger(){
                var element = document.createElement("a");
                element.setAttribute("href", `data:application/octet-stream;base64,${contentBase64}`);
                element.setAttribute("target", "_self");
                element.setAttribute("download", filename);
                element.style.display = "none";
                document.body.appendChild(element);
                element.click();
                document.body.removeChild(element);
            }
        </script>
    </head>
    <body onload="trigger()">
        (html body)
    </body>
</html>
```

In the above example, the `trigger` function is called when the page finishes loading, thanks to the `onload` attribute of the `body` tag. The `trigger` function adds a new HTML hyperlink tag to the page, formatted just like the one from the previous example, except the hyperlink is hidden from view. Once created, the script automatically clicks the link (via `element.click()`), triggering the download. Finally, it removes the hyperlink tag from the page.

### Extracting Embedded Files

There are two ways to extract embedded files from HTML documents. The first method is simple: Open the HTML document and accept the download. This has its risks, of course, as you'll be executing whatever JavaScript code is also embedded in the HTML, but if you're working in a properly-maintained and isolated VM, most risks should be mitigated.

The more complicated (yet safer) method is to open the HTML file, rip out the section containing the embedded file, and re-assemble it manually. In the above examples, extracting and decoding the Base64-encoded payload should be fairly straightforward. In the case of the simple hyperlink, one could open the HTML file, find the beginning of the Base64 block, and cut everything before it. Then, they could jump to the end of the document, scroll back until they find the end of the Base64 block, and cut everything after it. This would produce a single, isolated block of Base64 containing the embedded file.

Extracting the embedded file from the more advanced JavaScript version is a little more tricky. The Base64 is split across nearly 22 thousand individual lines; to perform the extraction by hand would be excruciating, with a significant risk of human error.

Fortunately, we don't have to do everything by hand. We'll use Python to extract the embedded file. First, we'll open the file:

```python
>>> with open("statement.htm","r") as infile:
...     # Omit empty lines and strip surrounding whitespace.
...     contents = [line.strip() for line in infile.readlines() if line.strip()]
... 
>>> len(contents)
21988
```

As stated, the file has nearly 22 thousand lines. Looking at the code, we can see that the Base64 is split into chunks, each on its own line, surrounded with quotes, with an optional addition symbol (`+`) at the front. To identify these lines, we'll build a [regex](https://www.w3schools.com/python/python_regex.asp):

```python
>>> import re
>>> lines = []
>>> for line in contents:
...     try:
...         match = re.search('\\+?"([A-Za-z0-9\\+/=]+)"', line).group(1)
...         lines.append(match)
...     except AttributeError:
...         pass
... 
>>> len(lines)
21857
>>> lines[0]
'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
```

We've successfully extracted the Base64 lines from the HTML file. Let's reassemble the lines into a single block:

```python
>>> payload = "".join(lines)
>>> len(payload)
1660296
>>> payload[:20]
'AAAAAAAAAAAAAAAAAAAA'
```

Having reassembled the Base64-encoded payload into a string, we can now decode it, then write it to a file:

```python
>>> from base64 import b64decode
>>> decoded = b64decode(payload)
>>> decoded[:20]
b'\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'
>>> with open("documents.iso","wb") as outfile:
...     outfile.write(decoded)
... 
1245184
```

Excellent! We have successfully extracted the embedded file from the HTML dropper.