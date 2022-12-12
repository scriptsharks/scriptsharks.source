---
title: "ScriptSharks Origins"
---

<h1>ScriptSharks Origins</h1>

_**Disclaimer:** This story is told from memory. I expect there will be inaccuracies. Where appropriate, I've invented code or console transcripts that attempt to represent data lost to time. I've recreated them as accurately as I can. I aim to tell the truth of my experience, though I cannot guarantee the veracity of every detail._

Grab a drink, pull up a seat, and I'll tell you the story behind **ScriptSharks.com**. I never knew the domain's original owner personally, but he (and his website) changed my life... Though, not in the way one might expect.

Read on, and you'll understand.

# Prologue

Back in 2001, I was a punk-ass wannabe hacker in high school. I'd been writing software for about six years, and after watching a [PBS Frontline Documentary on hackers](https://www.pbs.org/wgbh/pages/frontline/shows/hackers/), I became obsessed with the subject. I collected every scrap of data I could find, from low-bar "script kiddie" hack-tools to sophisticated exploitation whitepapers. I read books and 'zines (like [2600](https://www.2600.com/) and [PHRACK](http://www.phrack.org/)), watched videos, and infected my parents' PC with more malware than I care to admit. I learned about hacker history back to the '60s, about their culture and communities, and about famous groups like the [Masters of Deception](https://en.wikipedia.org/wiki/Masters_of_Deception) and the [Legion of Doom](https://en.wikipedia.org/wiki/Legion_of_Doom_(hacking)) (of the alleged "[Great Hacker War](https://en.wikipedia.org/wiki/Great_Hacker_War)"). I was insatiable.

# Attack

## Preparation

(MITRE: [T1593.002](https://attack.mitre.org/techniques/T1593/002/))

In 2003, after learning about [SQL Injection](https://www.w3schools.com/sql/sql_injection.asp) (SQLi), I was eager to practice what I'd learned. Back then, we didn't have sites like [HackTheBox](https://www.hackthebox.com/) providing practice labs. Even [HackThisSite](https://www.hackthissite.org/) was new, and was not well-known. Hackers had two choices: either get legal access to test hardware, or practice your skills "in the wild."

I was too broke to afford my own computer, let alone to buy a spare PC for "target practice," and I didn't know any other hackers IRL. I decided to take the risk and practice on live targets. (As a kid, rational thinking and sound judgment were not my strong suits.)

I used my [Google-fu](https://en.wiktionary.org/wiki/Google-fu) to search for vulnerable websites. I did a basic `inurl:login.php` search, and among the results, I found a link to **[scriptsharks.com](https://web.archive.org/web/20031229230816/http://www.scriptsharks.com/login.php)**. On visiting the site, I was excited to see that it was a site for programmers, including guides for PHP (which I was learning at the time). I decided to learn more about the site and its owner.

## Reconnaissance

(MITRE: [T1589](https://attack.mitre.org/techniques/T1589/), [T1592.002](https://attack.mitre.org/techniques/T1592/002/), [T1594](https://attack.mitre.org/techniques/T1594/), [T1595](https://attack.mitre.org/techniques/T1595/))

In 2000, Stephen "Gabriel" Lane (a.k.a. "Calico Jack")—a [motorcycle enthusiast](https://web.archive.org/web/20040421073844/http://scriptsharks.com/bike/index.php) and [Senior Software Engineer for the New Orleans Saints](https://web.archive.org/web/20030108200615/http://scriptsharks.com/resume.html)—created ScriptSharks.com as a place "[designed by a programmer for programmers](https://web.archive.org/web/20020125192310/http://scriptsharks.com/)," where he could share tutorials, manage code projects, and provide other resources for programmers. He was fluent in numerous programming languages, and provided the full source code for dozens of programs he'd written, all for free.

When I first started programming, back in 1995, I didn't have the Internet, and it was hard to find resources from which to learn. So I appreciated when successful people like Stephen shared their code and experience with the community. It seemed like he was living my dream, and he wasn't much older than me.

From his website, I knew that Stephen used the Linux operating system, and designed websites using PHP, hosted with Apache and MySQL. (A typical [LAMP stack](https://en.wikipedia.org/wiki/LAMP_(software_bundle)).) I scanned the server's ports; `22` and `80` were open, but not much else. These ports were provided by **OpenSSH** and **Apache**, each fully up-to-date and patched.

## Initial Access

Curiosity killed the cat. I'm glad I'm not a cat.

### Vuln Discovery

(MITRE: [T1588.006](https://attack.mitre.org/techniques/T1588/006/))

After learning about Stephen and his technical knowledge, I was excited to explore the guides and source code provided on his site. My first stop was his guide to designing [Sessions and Authentication Systems](https://web.archive.org/web/20031218204612/http://www.scriptsharks.com:80/articles/sessions.php) in PHP. My original goal was to practice SQLi attacks; it seemed likely that his site's auth code would be similar to that in his guide, which included SQL table layouts and code samples. If there was a vulnerability to be found, this was a good place to start hunting.

Here's the session-checking code from Stephen's guide:

```php
function is_logged_in() {
    global $session_id;
    $select = "SELECT Logged_In FROM Sessions WHERE Session_ID = '$session_id'";
    $result = mysql_db_query("Your DB", $select) or die (mysql_error() . "<HR>\n$select");
    $db = mysql_fetch_array($result);
    return $db[Logged_In];
}
```

And here's the logout code:

```php
session_start();
$session_id = session_id();
$insert = "UPDATE Sessions SET Logged_In = '0' WHERE Session_ID = '$session_id'";
$result = mysql_db_query("Your DB", $insert) or die(mysql_error() . "<hr />\n" . $insert);
```

On reading the code, I realized the `SELECT` query was not being sanitized in the `is_logged_in` function, nor was the `UPDATE` query in the logout code. Theoretically, someone could de-authenticate any user they wished, or authenticate as any user, as long as they had some way to control the contents of the `$session_id` variable.

Stephen had failed to sanitize database inputs in his guide; perhaps the same would be true of his login page?

### Vuln Confirmation 

(MITRE: [T1190](https://attack.mitre.org/techniques/T1190/))

I decided to test the login for SQLi vulnerabilities. If the `login.php` script were written similar to the code from his tutorial, the code would likely include a SQL query something like this:

```php
$select = "SELECT * FROM Users WHERE Username = '$username' AND Password = '$password' LIMIT 1";
```

When called on the database, the `$username` and `$password` variables would be substituted for user-provided values. If I entered `' OR '1'='1` as both the username and password, the query would return the first user in the database. In most cases, the first user in the database is an admin.

I did not actually expect my attack to work. Stephen's tutorial was intended to be basic, for the sake of learning. Considering the experience listed on his resumé, I expected the `$username` and `$password` variables to be sanitized before being passed to the database. So I was legitimately surprised when, upon executing my SQLi attack, I was successfully authenticated as the admin user, `sglane`.

"Holy crap," I thought. "I got in!" It was an incredible rush. I was simultaneously thrilled that my attack had worked, and terrified that I was going to get caught and arrested under the [CFAA](https://www.nacdl.org/Landing/ComputerFraudandAbuseAct) over a silly SQLi attack. (Funny how consequences only came to mind _after_ I'd done the attack.)

I hadn't caused any harm, though; and besides, this was Stephen's personal page, not attached to some hyper-litigious corporation. No harm, no foul, right?

My excitement outweighed my fear. I decided to press further. By altering my query, I could skip the `sglane` user and authenticate as the second user in the database:

* Username: `' OR '1'='1`
* Password: `' OR '1'='1' AND Username != 'sglane`

Executing the attack, I was successfully authenticated as the second user in the database. From there it was a simple matter to enumerate all the users, one by one, simply adding a new `Username != 'blah'` clause to the query for each discovered user.

Not bad for my first real-world attempt at SQLi!

### Account Compromise

(MITRE: [T1212](https://attack.mitre.org/techniques/T1212/), [T1552](https://attack.mitre.org/techniques/T1552/), [T1586](https://attack.mitre.org/techniques/T1586/))

I was quite pleased with my accomplishment, but I was not done yet. What good are usernames without passwords? I searched around, unable to find an obvious way to retrieve the password from the database. I decided to try "blind" injection, enumerating the password character-by-character:

* Username: `sglane`
* Password: `' OR Password LIKE 'a%`

If the password started with `a`, I'd be authenticated. Otherwise, I'd be returned to the login screen, where I'd check every subsequent character until I found a match. Then I could start on the 2nd character, and so on. Once I'd uncovered the first password, I could move on to the second username, and repeat the process. Without automation, this process could take ages, but I was young and optimistic, and people didn't often use random 20-character passwords back then.

Imagine my surprise when I found the complete password _on the first attempt._

After sending my injected credentials, the site rejected my attempt and returned me to the login page. However, I noticed that the login form had been re-populated upon my return, rather than preseting me with empty fields. "Curious," I thought. "What values are in the form fields?"

Viewing the page source code, I was appalled to discover that the login script, while refusing my attempt, had actually filled in the _correct password for the specified user_, taken straight out of the database. The password was right there, in clear-text, in the HTML of the page.

It appeared that Stephen had intended the script to re-populate the form fields with the user's original input upon returning to the login page, like so:

```php
<?php
$username = $_POST['username'];
$password = $_POST['password'];
$query = "SELECT Username, Password FROM Users WHERE Username = '$username' AND Password = '$password' LIMIT 1";
$result = mysql_db_query("Your DB", $query) or die(mysql_error() . "<hr />\n" . $query);
$values = mysql_fetch_array($result);
if($values['Username'] == $username && $values['Password'] == $password) {
    /* Redirect the user to the projects page. */
    header("Location: projects.php");
    exit;
} else {
    /* Show login fields again. */
?>
<form>
    <input type="text" name="username" value="<?php echo $username; ?>" />
    <input type="password" name="password" value="<?php echo $password; ?>" />
    <input type="submit" value="Login" />
</form>
<?php
    exit;
}
?>
```

However, there was a bug in Stephen's code: rather than using the values pulled from `$_POST`, he used the values returned by the database:

```php
[...]
$values = mysql_fetch_array($result);
[...]
<form>
    <input type="text" name="username" value="<?php echo $values['Username']; ?>" />
    <input type="password" name="password" value="<?php echo $values['Password']; ?>" />
    <input type="submit" value="Login" />
</form>
[...]
```

This is an easy mistake to make, and a difficult one to notice when troubleshooting. If my suspicion was correct, all I had to do was enter the correct username, along with an incorrect password, click "Login," then (after the login was rejected) click "Login" again, and I'd be authenticated as whichever user I wished.

I tried. It worked.

10 minutes later I had the passwords for _every single user of ScriptSharks.com_. I could log in as anyone, and see all the projects they had created on the site.

But that wasn't enough. I was feeling euphoric, my confidence boosted by my success. "How far can I go?" I thought. "Can I get root?"

### Password Reuse

(MITRE: [T1021.004](https://attack.mitre.org/techniques/T1021/004/), [T1078.003](https://attack.mitre.org/techniques/T1078/003/))

With a list of valid account credentials, I turned my attention to the **SSH** server running on port `22`. These days we consider it bad practice to re-use passwords for multiple accounts. However, back in 2002, password reuse was still quite common, and `sglane` was no exception.

I downloaded [PuTTY](https://www.putty.org/), an SSH client for Windows, and connected to ScriptSharks.com's SSH server, using the credentials I had recovered for `sglane`. The credentials worked, and I was presented with a command prompt.

## Privilege Escalation

(MITRE: [T1548.003](https://attack.mitre.org/techniques/T1548/003/))

Having gained access to the system as `sglane`, I wanted to elevate my privileges to `root`. Since `sglane` was an admin, I could simply use `sudo` to obtain root access, providing credentials when prompted:

```shell
sglane@webserver:~$ sudo su
[sudo] password for sglane:
root@webserver:/home/sglane#
```

This worked; I was logged in as `root`.

## Discovery

(MITRE: [T1003.008](https://attack.mitre.org/techniques/T1003/008/), [T1518](https://attack.mitre.org/techniques/T1518/), [T1083](https://attack.mitre.org/techniques/T1083/), [T1087.001](https://attack.mitre.org/techniques/T1087/001/), [T1552.001](https://attack.mitre.org/techniques/T1552/001/))

After obtaining `root` access, I explored the system further.

Reading the `/etc/passwd` file revealed the `www-data` account, which is the default account used by the **Apache** web server. (I could have also dumped the contents of `/etc/shadow` to see the password hashes for other accounts, but I did not have access to a password-cracking utility like [John the Ripper](https://www.openwall.com/john/) at the time, so I left the hashes alone.)

Looking in the `/var/www` directory (the default **Apache** webroot at the time), I discovered that `scriptsharks.com` had its own subdirectory, along with three others*:

```shell
root@webserver:/home/sglane# ls -lh /var/www
total 16K
drwxr-xr-x 2 root    root 4.0K Aug  9 18:15 onlineshop.com
drwxr-xr-x 2 root    root 4.0K Dec 30  2001 phpmyadmin
drwxr-xr-x 2 root    root 4.0K May 12 11:05 retailstore.com
drwxr-xr-x 2 root    root 4.0K Apr 19 05:02 scriptsharks.com
```

_* Note: I have long forgotten the domains for the two online shops Stephen managed, so I've used `onlineshop.com` and `retailstore.com` as generic substitutions._

Stephen was using one server to host ScriptSharks and two online retail stores, as well as the [phpMyAdmin](https://www.phpmyadmin.net/) web-based MySQL administration tool.

Browsing to the `scriptsharks.com` directory, I found the site's PHP source code, which included database connection credentials. The credentials appeared to be site-specific, with ScriptSharks and the online stores each using a separate account. However, upon visiting the `phpMyAdmin` service hosted on the website, I was able to authenticate as `sglane` using the password I'd recovered previously, and was able to access the databases for all three sites.

## Collection

(MITRE: [T1005](https://attack.mitre.org/techniques/T1005/), [T1560.001](https://attack.mitre.org/techniques/T1560/001/))

These databases included tables for user accounts, product information, customer orders, and more. They included cleartext usernames, emails and passwords for all accounts on all three sites, as well as details for every order placed on the two retail sites, including the customer's name, shipping address, and credit card information.

If a malicious hacker got access to these records, it could cause serious trouble for Stephen and his online businesses. Fortunately, my motivations were intellectual, not material; I had no interest in abusing the data. Quite the opposite! Following the discovery, I knew I had to talk to Stephen about securing his websites.

My predicament was this: How do I reveal the vulnerabilities in Stephen's websites so he'll take me seriously, without compromising system security, and without getting arrested for computer crimes? At the time, the concept of [Coordinated Vulnerability Disclosure](https://en.wikipedia.org/wiki/Coordinated_vulnerability_disclosure) was not yet widely known, despite the fact that vulnerability disclosure had been a subject of heated debate [since the 1800s](https://en.wikipedia.org/wiki/Full_disclosure_(computer_security)#The_vulnerability_disclosure_debate).

I weighed my options: If I claimed I had hacked his site without providing proof, he would dismiss my claims. What proof would suffice? A dump of the database would be sufficient; it would demonstrate that sensitive data was accessed, giving credibility to my claims. So I used `mysqldump` to export all databases to a single file:

```shell
root@webserver:/home/sglane# mysqldump --all-databases -u sglane -p secretpassword > /home/sglane/databases.sql
```

The resulting file was quite large, so I compressed it with `zip`, encrypting the contents with a password—the same password used to authenticate with the `sglane` account:

```shell
root@webserver:/home/sglane# zip -p secretpassword databases.zip databases.sql
```

I had my proof; now I needed to consider how to provide it. Malicious attackers would simply exfiltrate the file, eager to sell the data to credit fraudsters or cash-in themselves. However, I did not want the data to leave the system; not only would this look bad for me—committing actual data theft would undermine any ethical defense I could build—but it would also be a security risk for Stephen and his business. As it stood, the only way to steal the data would be to attack Stephen's systems. But if the same data were also on my own system or stored on the 'net somewhere, then the data would be at even greater risk of compromise simply by existing in multiple places.

Rather than exfiltrate the data prior to disclosure, I simply left the encrypted `databases.zip` file in Stephen's home directory, and deleted the original `databases.sql` dump file. Then I began drafting an email, letting Stephen know I had discovered vulnerabilities on his server, and had left the `databases.zip` file in his home directory as proof—encrypted with his own secret password. This way, I didn't have to transmit the password via email; I could simply say "use the same password you use everywhere else." Using his own password to encrypt the dump file provided additional proof of compromise.

## Impact

(MITRE: [T1485](https://attack.mitre.org/techniques/T1485/), [T1489](https://attack.mitre.org/techniques/T1489), [T1491](https://attack.mitre.org/techniques/T1491), [T1499](https://attack.mitre.org/techniques/T1499), [T1529](https://attack.mitre.org/techniques/T1529), [T1531](https://attack.mitre.org/techniques/T1531/), [T1561](https://attack.mitre.org/techniques/T1561), [T1565.001](https://attack.mitre.org/techniques/T1565/001/))

While my intentions were never malicious, I was sure to outline some of the risks inherent in the vulnerabilities I'd discovered. For example, there was the obvious risk of credit card fraud and identity theft from the customer data, but that was just the tip of the iceberg.

With access to the database, attackers could modify data. They could delete legitimate orders, or lock people out of their accounts. They could alter orders, rerouting legitimate purchases to the attackers' address. They could change prices, alter inventory levels, or double-charge customers. They could create new orders, mark them as paid but not shipped, and obtain free products from Stephen's stores. Or they could mark products as returned, but not yet refunded, and steal money.

Looking beyond the database, it would also be possible for attackers to deface Stephen's websites, alter their source code, host and transmit malicious code or other illicit data, use the site to conduct a phishing attack, and even use the site as a C2 server for a malware botnet.

If they're feeling destructive, attackers could use `sudo rm -rf /` command to wipe the server's filesystem. Or a fork-bomb could cause the system to become non-responsive. Or, if they're feeling lazy, they could simply `sudo shutdown -h now` to take the server offline.

But the impact wasn't limited to Stephen's systems. Stephen liked to re-use the same password across multiple accounts, and he wasn't alone. Doubtless many of his websites' users did the same. With access to the database of usernames and their associated email addresses and passwords, attackers could abuse this habit to gain unauthorized access to the external email accounts of Stephen's users. With this access, users could potentially defraud those users further, stealing sensitive data, gaining access to other accounts and services (such as online banking), and even using their legitimate email accounts for phishing attacks.

The possibilities were endless! And I made sure Stephen knew about them.

# Aftermath

After composing my email to Stephen, the adrenaline from my exploits had faded, and the reality of the situation began to set in. In my excitement and curiosity, I hadn't given much thought to the consequences of my actions. After writing about all the ways people might exploit Stephen's websites, I realized the risk I was taking, and considered whether to send the email or just wipe my tracks, deleting all evidence of my intrusion and pretending I'd never found the site.

While the "wipe my tracks" option looked appealing, my decision was influenced by two core assumptions:

* Everyone is smarter than me.
* Second, I assume I'm never the first to discover anything.

If I tried to cover my tracks, Stephen would find some logfile or other overlooked evidence of my intrusion. Even the act of covering one's tracks creates more tracks. Assuming that Stephen was smarter than me, I could not hope to hide my intrusion. I would be caught, one way or another.

But what if I knew I wouldn't get caught? I could still walk away as if I had never found the site, right? This is where the 2nd assumption comes in. Having discovered these vulnerabilities in Stephen's websites, I had to assume that someone else had discovered them first. This presented an ethical dilemma: Could I ignore the vulnerabilities, knowing that someone else could already be abusing them?

Consider the following (hypothetical) scenario: Say you're a tourist visiting the Eiffel Tower, and while leaning against the rail to snap a photo, you accidentally dislodge the railing. Looking at the damage, you realize that the rail could easily fall off, and if someone were to lean on it, they could potentially fall to their death.

If you report the broken railing, you might be accused of causing the damage. But if you don't report the damage, someone could get hurt or die. Therefore, despite the personal risk, the only ethical option would be to report the faulty railing, so that it could be repaired, and nobody would get hurt.

Likewise, despite the personal risk inherent in disclosure, I felt I could not ethically ignore the vulnerabilities in Stephen's websites, knowing that they could lead to great harm to Stephen and his users.

## Disclosure

My heart raced as I clicked "send" on the email. Shortly after, the bell rang for lunch. As I ate, I considered the very real possibility that I could be arrested for computer crimes. Despite my intentions, and my efforts to alert Stephen to the vulnerabilities in his systems, I could still go to jail. I had heard of minors being arrested and tried as adults. How would I survive incarceration? How would I explain this to my parents? My actions were indelible. The ball was in Stephen's court. All I could do was wait.

Suffice to say, it was a very anxious lunch.

Upon my return, I checked my inbox, and found an email from Stephen. He was, understandably, irate. He'd been having a pretty good day until I came along. Now he had a security incident on his hands, which could impact his reputation and his career. He felt endangered, and reacted defensively, threatening litigation against me.

## Remediation

It appeared my worst fears were coming true. Still, I felt disclosure was the right course of action. 

I explained as much in my response, and offered my advice on how to fix the vulnerabilities and improve his code security. I also encouraged him to implement better password hygeine, both in his databases and with his personal accounts. Finally, I reminded him of a few important details which, I hoped, would dissuade legal recourse:

1. I had taken no harmful actions on his system, and had not only disclosed the vulnerabilities, but provided solutions.
2. As a minor, I would likely receive a lighter sentence than an adult in my position.
3. At least one of the web-shops Stephen operated was for a business based in California.

[California law](https://oag.ca.gov/privacy/databreach/reporting) requires businesses to notify users whose unencrypted personal information may have been acquired by an unauthorized person. If Stephen took me to court for unauthorized access, he'd force the businesses whose websites he hosted to disclose the breach to their customers. This would cause a pile of problems for Stephen and his business clients. The businesses would suffer financial losses, and Stephen would incur damage to his reputation and career.

It seemed like a lot of unnecessary hassle, from my perspective, when instead Stephen could simply fix the bugs, change his passwords, and get on with his life.

I was glad to see that he agreed. The last email he sent was brief, effectively saying "I'll drop it this time. Don't hack me again." Not long after—some time between [December 31, 2003](https://web.archive.org/web/20031231072921/http://www.scriptsharks.com/) and [February 6, 2004](https://web.archive.org/web/20040206040744/http://scriptsharks.com:80/)—Stephen restructured his website, taking down the insecure project-management service altogether, and rearranging existing articles and projects to fill the space.

I never heard from him again, but I never forgot about Stephen, nor about ScriptSharks. My experience with him encouraged me to keep learning, keep hacking, and keep working to improve security for everyone. Though he never knew it, Stephen had a significant impact on my life.

# Retrospect

Over the years that followed, I checked in on ScriptSharks now and then. I watched as the site evolved, though activity dwindled. Stephen's last major revision to the site was around [December 3, 2004](https://web.archive.org/web/20050129040945/http://scriptsharks.com:80/), after which point he only updated the site a few times, usually to [update the copyright date](https://web.archive.org/web/20060117190400/http://www.scriptsharks.com:80/). In 2007, Stephen [stripped the news section from his site](https://web.archive.org/web/20070810100213/http://www.scriptsharks.com:80/).

In [2011](https://web.archive.org/web/20110416232547/http://www.scriptsharks.com:80/), the site was host to some Japanese domain-parking page. In [2013](https://web.archive.org/web/20130619175625/http://www.scriptsharks.com/) it appeared that ScriptSharks may make a comeback, but in [2016](https://web.archive.org/web/20160109235928/http://www.scriptsharks.com/) the site went offline, never to return.

Around that time, I was working as a long-haul trucker, making deliveries coast-to-coast. Despite my decades-long passion for coding and hacking, I had never considered myself good enough to "go pro." But in my down-time on the road, I connected with a group of hackers online, many of whom worked in the industry. After observing my skills, they urged me to pursue a career as a penetration tester. In 2019, I left trucking and obtained my [OSCP](https://www.offensive-security.com/pwk-oscp/). In 2020, I was hired as an entry-level security analyst.

Before long, I was teaching new analysts about pentesting methods and techniques. Each time I taught a team about SQLi, I would tell them the story of ScriptSharks.com, and how Stephen and his website had inspired me. As analysts, my students had been taught "zero trust," and were encouraged to fact-check everything. My story was no exception.

This is how, in 2021, I discovered that Stephen had passed away the previous year. One of my students, Googling for Stephen's name, found his [obituary](https://obits.nola.com/us/obituaries/nola/name/stephen-lane-obituary?id=2273886) on a local news website. I was saddened at the news. While I had never known Stephen personally, I had thought about him often. It was odd, feeling such a connection with someone I barely knew.

# Rebirth

In 2022, thinking back on Stephen's passing, I wondered: Who owns ScriptSharks.com now? I assumed it would have been bought up right away, but I was wrong. When I looked, the domain was for sale!

So I bought it. I didn't want it to fall in the hands of a domain-squatter with no appreciation for the site's history. I wanted to do something useful with it. Something that would respect the site's history, while taking it in a new direction.

I took a page from Stephen's book. I decided to channel my passion for malware and security into ScriptSharks.com, sharing my knowledge and experience with the world, just as Stephen had done.