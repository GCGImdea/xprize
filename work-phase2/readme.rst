============================================
 CORONASURVEYS XPRIZE Challenge - Phase 2
============================================

The instructions here are very specific to our setup. They are only here as a reminder;
they are not intended to be comprehensive information.

----------------------
Sandbox Installation
----------------------

First and foremost clone our repo like this in ~:

  git clone --depth 1 https://github.com/GCGImdea/xprize.git


Then install some necessary, but also some useful, packages/libs to install:

  conda install -y git rsync nano htop

  conda install -y -c r r-essentials r-tidyverse r-geometry


And some Python libraries:

  pip install -r requirements.txt


----------------------
 Updating the Code
----------------------

Assuming you have already completed the Sandbox Installation, you may now want to update the code in the sandbox:

  cd ~/xprize

  git pull

  rsync -av ~/xprize/work-phase2/ ~/work/


----------------------
 Trying it oute
----------------------

You are supposed to run:

  ~/.hourly/run.sh

This may not do much if there is already an existing output file for the parameters provided.
To overcome this, you should remove the CSV files in ``~/work/prescriptions`` that are mentioned
as ``skipped`` in the log output of the run.sh script.

