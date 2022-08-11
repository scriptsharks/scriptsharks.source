---
title: "ScriptSharks Origins"
---

Story time. Before I bought ScriptSharks.com in 2022, it belonged to a programmer by the name of Stephen Gabriel Lane (a.k.a. "Calico Jack"). What follows is a detailed account of the site's origins, how I came to know of it, and how Stephen (and ScriptSharks.com) changed my life.

# Setting the Stage

Stephen started ScriptSharks in 2000, wanting to provide a site "[designed by a programmer for programmers](https://web.archive.org/web/20020125192310/http://scriptsharks.com/)," where he could share tutorials, manage code projects, and provide other resources for programmers. Stephen also provided the full source code for dozens of programs in multiple languages. He shared all his work for free, without ads, all while [pursuing his passion for motorcycles](https://web.archive.org/web/20040421073844/http://scriptsharks.com/bike/index.php) and [working for the New Orleans Saints and Clear Channel Communications as a Senior Software Engineer](https://web.archive.org/web/20030108200615/http://scriptsharks.com/resume.html).

Truly a go-getter.

By 2002, I had been writing software for about seven years, and had discovered my passion for hacking. After watching a [PBS Frontline Documentary on the subject](https://www.pbs.org/wgbh/pages/frontline/shows/hackers/), I devoured every scrap of data I could find, from low-bar "script kiddie" hack-tools to sophisticated software exploitation walk-throughs. I read books, watched videos, and infected my parents' PC with more malware than I care to admit. I learned about hackers all the way back to the '60s, about the history and culture of the hacker community, and about (in)famous hacker crews like the [Masters of Deception](https://en.wikipedia.org/wiki/Masters_of_Deception) and the [Legion of Doom](https://en.wikipedia.org/wiki/Legion_of_Doom_(hacking)) (of the alleged "[Great Hacker War](https://en.wikipedia.org/wiki/Great_Hacker_War)"). I was insatiable.

# Enumeration

Shortly after learning about [SQL Injection](https://www.w3schools.com/sql/sql_injection.asp), I began Googling around to see if I could find any vulnerable websites. I did a basic `inurl:login.php` search, and among the results, I found a link to ScriptSharks.com. On visiting the page, I was excited to see that it was a site for programmers, including guides for PHP (which I was learning at the time). One of the guides covered [Sessions and Authentication Systems](https://web.archive.org/web/20031218204612/http://www.scriptsharks.com:80/articles/sessions.php), including SQL table layouts and code for checking and terminating user sessions.

Here's the session-checking code:

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

Exploring the site further, I found that Stephen provided project management tools for users of the site, allowing them to create accounts and manage code projects. The site included a [login page](https://web.archive.org/web/20031229230816/http://www.scriptsharks.com/login.php), written in PHP, presumably with a SQL backend.

Naturally, I decided to test the login page for SQL injection vulnerabilities. If the `login.php` script were written similar to the code from his tutorial, the code would likely include a SQL query something like this:

```php
$select = "SELECT * FROM Users WHERE Username = '$username' AND Password = '$password' LIMIT 1";
```

When called on the database, the `$username` and `$password` variables would be substituted for user-provided values. If I entered `' OR '1'='1` as both the username and password, the query would return the first user in the database (likely the admin user).

Now, I did not actually expect this to work. Stephen's tutorial was intended to be basic, for the sake of learning. Considering Stephen's experience and impressive resumé, I expected the `$username` and `$password` variables to be sanitized before being passed to the database. So I was legitimately surprised when, upon executing my SQL Injection attack, I was successfully authenticated as the admin user, `sglane`.

"Holy crap," I thought. "I got in!" It was an incredible rush. I was simultaneously thrilled that my attack had worked, and terrified that I was going to get caught and arrested under the [CFAA](https://www.nacdl.org/Landing/ComputerFraudandAbuseAct) over a silly SQL injection attack.

My excitement outweighed my fear, however, and I decided to press further. By altering my query, I could skip the `sglane` user and authenticate as the second user in the database:

* Username: `' OR '1'='1`
* Password: `' OR '1'='1' AND Username != 'sglane`

Executing my attack, I was successfully authenticated as the second user in the database. From there it was a simple matter to enumerate every user, one by one, simply adding a new `Username != 'blah'` clause to the query for each discovered user.

Not bad for my first real-world attempt at SQL Injection!

# Exploitation

I was quite pleased with my accomplishment, but I was not done yet. What good are usernames without passwords? I searched around, unable to find an obvious way to retrieve the password from the database. In desperation, I decided to try enumerating the password character-by-character, via a "blind" injection:

* Username: `sglane`
* Password: `' OR Password LIKE 'a%`

If the password started with `a`, I'd be authenticated. Otherwise, I'd be returned to the login screen, where I'd check `b`, then `c` and so on, until I found the correct first character. Then I could start on the 2nd character, and so on. Once I'd uncovered the first password, I could move on to the second username, and repeat the process. Without automation, this process could take ages, but I was young and optimistic, and people didn't often use random 20-character passwords back then.

Imagine my surprise when I found the complete password _on the first attempt._

After sending my injected credentials, the site rejected my attempt and returned me to the login page. However, I noticed that the login form had been re-populated upon my return, rather than preseting me with empty fields. "Curious," I thought. "What values are in the form fields?"

Viewing the page source code, I was appalled to discover that the login script, while refusing my attempt, had actually filled in the _correct password for the specified user_, taken straight out of the database. The password was right there, in clear-text, in the HTML of the page.

It appeared that Stephen had designed the script to re-populate the form fields with the user's original input upon returning to the login page, like so:

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

However, Stephen had made an easy mistake when coding the page: rather than using the values pulled from `$_POST`, he used the values returned by the database:

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

I tried it. It worked.

10 minutes later I had the passwords for _every single user of ScriptSharks.com_. I could log in as anyone, and see all the projects they had created on the site.

But that wasn't enough. "How far can I go?" I thought. "Can I get root?"

_Note: If Stephen had stored password hashes, rather than clear-text credentials, I would have recovered the hashes, which I'd have to crack before they could be useful. This wouldn't solve the underlying vulnerability, but would at least have made clear-text password recovery more challenging._

# Privilege Escalation