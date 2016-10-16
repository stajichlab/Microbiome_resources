
Some steps to getting started working on these projects.

Setup ssh keys in your git account
https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/

```git clone REPOSITORY```
e.g. 
```git clone git@github.com:stajichlab/Microbiome_EarthCube_2016-05.git```

Now you have a copy in your account (you might do this in ~/bigdata on cluster) - you can also check this out on your laptop so you can view the .html files from qiime. You can also use it to edit the .csv files in Excel and that can be saved. You can also use the git desktop client for graphical access on your mac - https://desktop.github.com/

Anytime you want to make sure you have the latest version you can get that with 
```git pull```

by default you are on the master branch which is the default. If you want to make your own branch to try things out on
```git branch MYBRANCH
git checkout MYBRANCH```

you can go back to another branch (e.g. master)
```git checkout master```

The code for the qiime pipeline and others is:
https://github.com/stajichlab/Microbiome_resources
e.g.

```git clone git@github.com:stajichlab/Microbiome_resources.git```

I am going to fix the project repos a bit so they can actually automatically check out a version of this code within their repositroy via 'submodules'
* https://gist.github.com/gitaarik/8735255
* https://stackoverflow.com/questions/1605824/git-nested-repos
* https://github.com/blog/2104-working-with-submodules

So you do some stuff, you want to check this in to share
If there are new files 

```git add FILE```

or 

```git add DIRECTORY```

I am trying to not check in intermediate files into the repo - only the starting files, configuration files, and the final reports - but ask if you aren't sure. There are size limits on github repos with the default settings, files/commits > 100Mb are not allowed. So try to look at what you are committing in terms of reports or temp files before you do a git add 
You can do a 

To remove a file: ```git rm ```

You can use ```git mv OLD NEW```
to rename a file that is being tracked.

Commit a specific folder or directory: ```git commit -m "a message about this commit" FILE-or-DIRECTORY```
Commit everything in the current folder: ```git commit -m "a message about everything to be committed in this whole directory or below"```

this will make the commit to your local copy of the repository but everyone else still cannot see this - only when you do ```git push``` is it copied to the github server so that everyone else can pull it down.

All the Microbiome project data are private for the time being but the Microbiome_resources repository is public.
