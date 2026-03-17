## SESSION 01: THE SCAVENGER HUNT [NIGHT 1]

<!--Objective: Map the Filesystem Hierarchy Standard (FHS), navigate restricted directories, and extract hidden system intel for your GitHub portfolio.-->


**STEP 1: THE SYSTEM PATCH**
<!--Command Format:--> curl -sL https://gist.githubusercontent.com/grobbins-cell/0aaa074ff77fca0b4cb8e097820d970a/raw/07abd5680a7db4a57e050594f35baf6a9ec03c48/setup_lab_01.sh | bash 
<!--[This link has been provided by the instructor to build the environment for the lab]--> <br>

**STEP 2: TARGET ACQUISITION**
**Target 1: The system Logs. <br> Task: Navigate to the log directory and verify the existence of syslog and auth.log.**
commands: 
        <br>  cd /var/log
        <br> ls

<br>

**Target 2: The Secret Mission <br> Location: /opt/alpha. Task: Step into the "Optional Software" directory and read the mission file.** <br>
Commands:
        <br>    cd /opt/alpha
        <br>    ls
        <br>    cat mission.txt

**Target 3: The Hidden Token. <br> Location: /var/tmp. Task: Find a "hidden" directory and extract the digital token inside.**

commands:
        <br>    cd /var/tmp <!--Move to the temp directory# -->
        <br>    ls -la   <!--Reveal hidden files (files starting with a dot)-->
        <br>    cd .blackout <!--Enter the hidden folder-->
        <br>    cat token.txt <!--Read the token-->


**STEP 3: THE ARTIFACT (DISCOVERY.TXT)** <!--document your findings in your home directory-->

commands:
        <br>    cd ~ <!--Return home command-->
        <br>    nano discovery.txt <!--Create the report named discovery.txt-->
        <!--Enter the Intel: Type the following into the editor:
        Log Path: /var/log/syslog
<!--Mission Path: /opt/alpha/mission.txt
Mission Secret: [Paste the secret message here]
Token Path: /var/tmp/.blackout/token.txt
Token Secret: [Paste the token number here]-->

**STEP 4: THE PORTFOLIO PUSH (EXFILTRATION)**
Move the File: mv ~/discovery.txt ~/your-repo-name/
Enter Repo: cd ~/your-repo-name/
Stage & Commit: ```bash
git add discovery.txt
git commit -m "sec: completed session 01 scavenger hunt"
Push: git push origin main