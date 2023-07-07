# Defender.bat
This script is intended to be used with hMailServer to verify messages for viruses with Windows Defender.

I am no fan of anti-virus software. They are costly, slow down the system and some are a pain to update. I had some hard times in the past with ClamWin and ClamAV, with my system locking up frequently as a crash on one of those was not correctly solved. So,
when I migrated hMailServer to my new Windows Server 2022 I was thrilled with the prospect of not needing a third party antivirus anymore. Windows Defender comes integrated with the system, with no extra cost, updates with the rest of Windows and, as far as I have experienced it on my desktop computer, works well and lightly.

My hopes of a bright tomorrow on my new server soon became despair, as I was flooded with complaints from my users about false positives. It made no sense to me why it was not working. I knew it gives the same errorlevel 2 for an identification or an error, but I was not expecting an error. At least not so often.

I was not inclined to go back to third party softwares, so I started logging the scans. A pattern soon arose. It was an error accessing the file to be scanned. It could not lock on it, for some reason. Out of the blue I had this idea to put a delay on the scan, so it should wait a few seconds before starting the job. It worked perfectly! No more false positives, however, it slowed the delivery and the message queue started to grow.

In order to keep things fast and at the same time avoid false positives, I had this idea of scanning the file twice. If it goes well on the first run, life goes on and the message is delivered. If it ends with an error, it should be checked again after a delay. As I am not an expert on batch files, I asked for help from my new friend, ChatGPT. Working together we came out with the script you find here

# Usage:
Just set up the paths for your log files and add the following to hMailServer’s External Virus Scanner tab:

Scanner executable: "C:\Your_Path\Defender.bat" "%FILE%"

Return value: 2


Contributions are welcome. Just ask me for a branch.
