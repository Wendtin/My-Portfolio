# ESSION 01: THE SCAVENGER HUNT

<!--Objective: Map the Filesystem Hierarchy Standard (FHS), navigate restricted directories, and extract hidden system intel for your GitHub portfolio.-->


**STEP 1: THE SYSTEM PATCH**
<!--Command Format:--> curl -sL https://gist.githubusercontent.com/grobbins-cell/0aaa074ff77fca0b4cb8e097820d970a/raw/07abd5680a7db4a57e050594f35baf6a9ec03c48/setup_lab_01.sh | bash [This link has been provided by the instructor to build the environment for the lab]

**STEP 2: TARGET ACQUISITION**
**Target 1: The system Logs. Task: Navigate to the log directory and verify the existence of syslog and auth.log.**
commands: 
            cd /var/log
            ls

img: ![screeshot step 1](<● README.md - Documents [SSH: 127.0.0.1] - Visual Studio Code_001-1.avif>)


**Target 2: The Secret Mission [Location: /opt/alpha. Task: Step into the "Optional Software" directory and read the mission file.**
Commands:
            cd /opt/alpha
            ls
            cat mission.txt
img: ![Target 2: The Secret Mission](<● README.md - Documents [SSH: 127.0.0.1] - Target 2: The Secret Mission-1.avif>)

**Target 3: The Hidden Token [Location: /var/tmp. Task: Find a "hidden" directory and extract the digital token inside.**

commands:
            cd /var/tmp <!--Move to the temp directory# -->
            ls -la   <!--Reveal hidden files (files starting with a dot)-->
            cd .blackout <!--Enter the hidden folder-->
            cat token.txt <!--Read the token-->
img: ![Target 3: The hidden Token](<● README.md - Documents - target 3-1.avif>)