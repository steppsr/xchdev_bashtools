# XCHDEV Bash Tools

# nftmon

**nftmon** is a tool to identify when the quantity of a nft wallet changes and send an alert email.

**Download**
You can down the nftmon.sh script and save into a folder you want to use for the application.
I created a folder for "xchdev_bashtools" in my home folder, and then have subfolder for each individual tool. For example:
```
mkdir ~/xchdev_tools/nftmon
```

**Need software packages**
You will need to provide your sudo password to complete these steps. And each one may take a few moments to install.

```
sudo apt install curl

sudo apt install ssmtp

sudo apt install jq

sudo apt install tr
```

**Setting up ssmtp (using a Gmail account)**
Since I have 2-factor authentication turned on for Gmail in order to get my Gmail account set up in ssmtp I had to set up an App Password. Below is a link to Google on how to do that, but I also listed the steps out. You will need to securely save that App Password. I will use  _APP_PASSWORD_  as a placeholder in the code, you need to replace that with your actual App Password.

Also, email isn't required so you can skip this step if you aren't comfortable with an App Password.

Reference:  [https://support.google.com/mail/answer/185833](https://support.google.com/mail/answer/185833)

1.  Goto your Google Account:  [https://myaccount.google.com/](https://myaccount.google.com/).
2.  Select Security.
3.  Under "Signing in to Google," select App Passwords. You may need to sign in. If you don’t have this option, it might be because:

	-   2-Step Verification is not set up for your account.
	-   2-Step Verification is only set up for security keys.
	-   Your account is through work, school, or other organization.
	-   You turned on Advanced Protection.

5.  At the bottom, choose Select app and choose the app you are using and then Select device and choose the device you’re using and then Generate.
6.  Follow the instructions to enter the App Password. The App Password is the 16-character code in the yellow bar on your device.
7.  Tap Done.

Now let's edit the ssmtp configuration file and add your Gmail details:

```
sudo nano /etc/ssmtp/ssmtp.conf
```

Change the  **root**  to your email address, change the  **mailhub**  to Gmail, and change the  **hostname**  to your computer (I'm using jabba because that is my farming rig's name).

```
root=username@gmail.com
mailhub=smtp.gmail.com:465
hostname=jabba
```

Finally, at the bottom of the configuration file, add the following lines. Be sure to update the **AuthPass** with your App Password from Google.

```
AuthUser=username@gmail.com
AuthPass=APP_PASSWORD
UseTLS=YES
```

Let's send a test email and make sure it works. Replace  _username@gmail.com_  with your email address.

```
printf "Subject: Testing SMTP Email\n\nThis is a test email." | /usr/sbin/ssmtp username@gmail.com
```

You should have received an email in your Gmail inbox.

**How to run the script**
```
bash nftmon.sh
```

**Change the permissions to make the script executable**
```
chmod +x nftmon.sh
```

**Add the script into Crontab**
Let's add a line into crontab so the script will run every minute. First open crontab.
```
crontab -e
```

Then add the following to run every minute.
```
* * * * * YOUR_APP_FOLDER/nftmon.sh
```
Real example:
```
* * * * * ~/xchdev_tools/nftmon/nftmon.sh
```
