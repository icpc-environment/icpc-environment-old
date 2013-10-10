ICPC Contestant Environment
========================
This repository contains some scripts and tools to build the contestant environment used at the ACM SER Programming Contest.  It should be easily adaptable to other sites/contests.

## Features!
* Support for 11 different Languages
    * c, c++, c#, (Oracle) Java 7, Scala, python(2/3), Haskell, ADA, Fortran, Pascal, Lua
* Includes common development tools
    * Eclipse(With PyDev and CDT)
    * (g)vim/emacs
    * gedit
* Developer Documentation Included
    * Java 7 API
    * C++ STL
    * Haskell Libraries/API
    * Pascal Manuals
    * Python 2.7
* Firewalled/locked down privileges for the contestant
* Runs entirely from a USB Flash Drive(minimum 8gb)
* Provides contestants a fat32 partition to store their code into so it can be easily reviewed from any Windows/Linux/Mac machine later.
* Fully customizable, heavily automated process for building consistent images.
* Lightweight XFCE window manager

## Download:
You can read a little bit more about the environment or download a copy of it here:
[ACM SER 2013 Contestant Image](http://ser.cs.fit.edu/ser2013/environment.html)

## Build instructions
### Build Requirements
If you want to build your own version of the environment or customize it, there are a few requirements you must satisfy before you get started.

First, you need to download and place the following in the `dist/` directory:
* eclipse (32/64 bit versions depending on your needs)
* Oracle Java JDK (32/64bit versions, again depending on your needs)

Other requirements:
* [Vagrant](http://www.vagrantup.com/)
* [VirtualBox](https://www.virtualbox.org/)

You also need to fetch the git submodules that are in use.  You can do this by:
```
git submodule init
git submodule update
```
Lastly, copy the file `chef/data_bags/contestenv/contest.json-dist` to `chef/data_bags/contestenv/contest.json`


### Building
It's pretty simple at this point, simply run `vagrant up`.  This will launch the VM, run the chef-solo provisioner and configure the environment exactly as specified.  On an i7 2600 using an apt-caching server, this process takes right around 11 minutes to complete. Once it's done, you have a few options.

When you've decided that your image is perfect, run `/icpc/scripts/makeDist.sh` from the icpcadmin user to clean up a few things, then poweroff the machine.

Open a terminal to the directory where the box-disk1.vmdk file lives(On windows, you can find this by right clicking on the VM in virtualbox and clicking "show in explorer").  Next run the following command to create a raw disk image that you can then `dd` onto a flash drive or hard drive.
```
VBoxManage internalcommands converttoraw box-disk1.vmdk disk-image.dd
```
Note: You may have to specify the full path to VBoxManage, for me it lives in `/cygdrive/c/Program\ Files/Oracle/VirtualBox/`

# Customizing
Now comes the fun part.  You can take our image as it is and it'll more or less work, but the firewall will prevent you from accessing everything except for our contest.
## contest.json
In `chef/databags/contestenv/` there is a file called `contest.json`.  This file contains many of the basic properties for the system, including administrative credentials, timezone information and firewall rules.  You **will** want to customize this file.

## default.rb
The file `chef/site-cookbooks/icpc-environment/attributes/default.rb` is worth taking a look at as well.  You'll need to make sure your Eclipse and JDK filenames match, or edit the file to point to the correct ones.

## Custom scripts
Scripts used at our contest provide various features, and you might want to customize them.  They are located in `chef/site-cookbooks/icpc-environment/templates/default/scripts/`.  If you want to rename or add a new script here, you will also need to update the `scripts` variable in `chef/site-cookbooks/icpc-environment/recipes/scripts.rb`.

## Custom Background
You can place a custom background image to be used for the contestants in `dist/wallpaper.png`.

## User Profile Customization
To customize the desktop icons, firefox bookmarks, or any other settings that are specific to a user's profile you have two options.
1. Make the changes manually and somehow try to keep track of what you did so you can apply them next time you build an image(not recommended)
2. Make the changes manually, then commit them into the git repository and push it upstream, so it will be used next time you build.

By deafult the user profile is deployed from /etc/skel, which is a git repository.  It will initially be on a different branch(chef does this for you).  You should probably run: `git checkout master`.  Then `git add` the files you want to include(try to think about whether it is necessary or not; there are lots of cache type files that are not strictly necessary to include).  Follow this with a `git commit` and a `git push` and your changes will be used next time the VM is rebuilt.

To change the repository location, you will need to edit the `attributes/default.rb` file as described above.  It is recommended to fork the repositories on github and update the urls as appropriate.

The 'icpcadmin' user has their own git repository that the user is deployed from, so you have two different "profiles" that you can manage.  I recommend placing shortcuts on the desktop of the admin user that link to the various administrative scripts available.

## Advanced customization
The entire contestant environment is build from a very minimal ubuntu image by chef, a wonderful configuration management tool.  If you need more functionality than what is provided, feel free to directly edit the recipes or templates to accomplish what you need to do.

# Feedback/Suggestions
Please use the GitHub Issue Tracker to file any bugs you encounter or to request additional features.  You can email the lead developer for this project: kj@ubergeek42.com.