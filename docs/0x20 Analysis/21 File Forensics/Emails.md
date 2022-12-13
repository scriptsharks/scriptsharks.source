---
title: "Emails"
---

# Introduction

Email is a ubiquitous form of communication, and has been one of the most-abused initial-access vectors throughout malware history. Whether exploiting vulnerabilities in the email client, or simply tricking the user into opening a malicious attachment, email is a fast and easy way to distribute malware.

# EML Files

When reporting a malicious email, it is common for users to export the email as an `.eml` file, enabling them to safely pass the email along without risking further infection. In Outlook, this can be done by right-clicking the email and selecting "Forward as Attachment." The resulting attachment will be an `.eml` file, which is a simple text file containing the email headers and body, as well as any included attachments. (For more information on `.eml` file syntax and structure, check out [the documentation over at FileFormat.com](https://docs.fileformat.com/email/eml/).)

## Dynamic Analysis

The quickest way to see what's in an `.eml` file is to open the email in an email client, such as Outlook. This is also the most dangerous approach, as it will execute any embedded macros or scripts. For this reason, it is recommended that you use a virtual machine or sandboxed environment for this analysis. Be sure to use a snapshot, so you can revert to a clean state if necessary.

By using an email client (preferrably the one used by the phishing target), you can see the email as its author intended. You can see the message, the formatting, and embedded images or attachments. Phishers will often attempt to imitate the look and feel of legitimate emails, such as password-reset reminders or overdue payment notices. By viewing the email in an email client, you can see how the phisher crafted their deception. You can also extract attachments and images from the email, which may contain malware.

One of the risks of this method is accidental execution of embedded code, or triggering call-backs to attacker-owned systems. For example, if the email loads a remote image, simply retrieving the image can give the attacker your IP and notify them that their phishing message was opened on your system. If the email exploits the email client, it could execute arbitrary code, and/or forward itself to all of the contacts in the system's address book. For these reasons, it's a good idea to keep your address book empty, and to disconnect the system from the Internet before opening the email.

## Static Analysis

If you don't want to risk executing the email, you can open it in a text editor. This will allow you to see the email headers and body, as well as any embedded attachments. However, you won't be able to see the formatting or images, and attachments will need to be extracted from the email before they can be analyzed. To top it off, the email will be in a format that is difficult for humans to read, and will require some effort to parse.

To make life easier, you can parse emails in Python using the `email` module. This module provides a number of classes and functions for parsing and generating email messages. Here's an example of how to parse an email in Python:

```python
>>> import email
>>> with open("suspicious.eml", "r") as f:
...    eml = email.message_from_file(f)
```

This parses the email into a `Message` object, which is stored in the `eml` variable. To see the available headers that can be retrieved via the `get()` method, you can use the `keys()` method:

```python
>>> eml.keys()
['Received', 'From', 'To', 'Subject', 'Thread-Topic', ...]
```
You can then access the email headers using the `get()` method:

```python
>>> print(eml.get("From"))
Clive Russel <clive.russel@scriptsharks.com>
>>> print(eml.get("Subject"))
Re: Billing Statement
```

To determine the content type of a `Message` object, you can use the `get_content_type()` method:

```python
>>> eml.get_content_type()
'multipart/mixed'
```

While some emails are simple and contain only a few headers and some text, others may comprise numerous conjoined sections. These are called "multipart" emails, and are often used to send HTML-formatted emails with embedded images or attachments. To determine whether an email is multipart, you can also use the `is_multipart()` method:

```python
>>> eml.is_multipart()
True
```

To retrieve the contents of the email, you can use `get_payload()`. If the email is not multipart, this will return the body of the email as a string. If the email is multipart, this will return a list containing additional `Message` objects representing each part of the email:

```python
>>> eml.get_payload()
[<email.message.Message object at 0x107bc0340>, ...]
```

Each of these objects can be parsed in the same way as the original email, and may themselves contain additional sections. To list all the parts a multipart email, you can use the `walk()` method:

```python
>>> for part in eml.walk():
...     print(part.get_content_type())
... 
multipart/mixed
multipart/alternative
text/plain
text/html
text/html
```

The `walk()` method returns a generator object which itself returns an `Message` object for each part of the email. You can capture them in a list like so:

```python
>>> parts = list(eml.walk())
>>> parts
[<email.message.Message object at 0x1074206d0>, ...]
>>> parts[0].get_content_type()
'multipart/mixed'
```

You can check the filename and size of each part:

```python
>>> for index, part in enumerate(parts):
...     if type(part.get_payload()) == str:
...         print(f"{index}: {part.get_filename()} ({len(part.get_payload())} bytes)")
...     else:
...         print(f"{index}: {part.get_content_type()}")
... 
0: multipart/mixed
1: multipart/alternative
2: None (249 bytes)
3: None (3664 bytes)
4: statement.htm (2691657 bytes)
```

In the above example, the two `None` parts are likely the body of the email, and the `statement.htm` part is the embedded attachment. We can grab the content of each section:
    
```python
>>> parts[2].get_payload()
'Hi Gully,\n\nPlease review the attached billing statement and let me know ...'
>>> parts[3].get_payload()
'<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:w="urn:schemas...'
```

Modern email clients often include both a plaintext and HTML-formatted version of the email. This allows the client to display the email in the format that the user prefers. The two above sections represent the plaintext and HTML versions of the message body.

To view a flat representation of a Message object, you can use the `as_string()` and `as_bytes()` methods:

```python
>>> # View message as string:
>>> strpart = parts[4].as_string()
>>> strpart[:70]
'Content-Type: text/html; name="statement.htm"\nContent-Description: sta'
>>> # View message as bytes:
>>> binpart = parts[4].as_bytes()
>>> binpart[:70]
b'Content-Type: text/html; name="statement.htm"\nContent-Description: sta'
```

Sometimes it may be beneficial to export the contents of a `Message` object. For example, the `statement.htm` attachment is a large and unwieldly HTML file, making it hard to manipulate in an interactive Python session. It will be easier to analyze the file in a text editor or browser. To extract the contents of a `Message` object, you can retrieve the object's payload:

```python
>>> contents = parts[4].get_payload()
>>> contents[:70]
'PCFET0NUWVBFIGh0bWw+CjxodG1sPgo8aGVhZD4KICAgIDxzdHlsZT4KICAgICAgICBodG'
```

In this case, the payload is Base64-encoded. We can decode this with the `base64` library:

```python
>>> from base64 import b64decode
>>> decoded = b64decode(contents)
>>> decoded[:70]
b'<!DOCTYPE html>\n<html>\n<head>\n    <style>\n        html {\n            f'
```

From here, it is fairly simple to save the decoded `statement.htm` file:

```python
>>> fname = parts[4].get_filename()
>>> fname
'statement.htm'
>>> with open(fname, "wb") as outfile:
...     outfile.write(decoded)
... 
1992525
```

In the above example, we use the `get_filename` from the `Message` object to find the original name of the attached file. However, we could just as easily name it whatever we want. Once the file has been written, it can be analyzed on its own:

```sh
analyst@labvm email_sample % head -n 10 statement.htm 
<!DOCTYPE html>
<html>
<head>
    <style>
        html {
            font-size: calc(1em*.625);
            -webkit-tap-highlight-color: rgba(0, 0, 0, 0);
        }
        body {
            font-family: "Segoe UI", "Helvetica Neue", Helvetica, Arial, sans-serif;
analyst@labvm email_sample %
```

For more information on using Python to manipulate `.eml` files, check out the [official documentation](https://docs.python.org/3/library/email.html).