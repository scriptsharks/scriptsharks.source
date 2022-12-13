---
title: "HTML and JavaScript"
---

<h1>HTML and JavaScript</h1>

## Embedded File Downloads

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
                "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
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

### Extracting Embedded Downloads

There are two ways to extract embedded files from HTML documents. The first method is simple: Open the HTML document and accept the download. This has its risks, of course, but if you're working in a VM most risks should be mitigated by the ability to roll-back the VM to a previous snapshot.

The more complicated (yet safer) method is to open the HTML file, rip out the section containing the embedded file, and re-assemble it manually. In the above examples, extracting and formatting the Base64-encoded payload should be fairly straightforward, if a little time-consuming. Once the encoded payload has been extracted, it can be decoded with Python or another language.