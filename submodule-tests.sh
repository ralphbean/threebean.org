#!/bin/bash
# The following bash script demonstrates how updates to submodules do not
# propagate between clones of 'super-repositories' (repositories which
# themselves have submodules).
#
# This script was created to show the necessity of a server-side git hook to
# perform a 'git submodule update --init' in RedHat's OpenShift Express.
#
# Copies of this script can be found here:
#   HTML:  http://threebean.org/submodule-tests.html
#    raw:  http://threebean.org/submodule-tests.sh
#
# Author:  Ralph Bean <ralph.bean@gmail.com>

homebase=$(pwd)

echo "* Trying to remove old repos from previous runs."
rm -rf repo1 repo2 cloned

echo "* Making new test repos with some junk data."
mkdir repo1 repo2
echo "hai" >> repo1/foo
echo "bai" >> repo2/bar
pushd repo1 && git init && git add foo && git commit -m 'Initial commit.' && popd
pushd repo2 && git init && git add bar && git commit -m 'Initial commit.' && popd

echo "* Adding repo2 as a submodule of repo1"
pushd repo1 && git submodule add $homebase/repo2 && git commit -m 'Added repo2 as a submodule' && popd

## Even if you try to do perform a submodule update on your original repository,
## the following demonstration plays out the same.  These lines are not
## necessary, and have no effect.
#pushd repo1
#git submodule update            # Let's try this
#git submodule update --init     # This too, just for kicks
#popd

echo
echo "-----------------------------------------------------------------"
echo "* Here, we expect repo1/repo2/bar to exist and contain 'bai':"
ls -al repo1/repo2
cat repo1/repo2/bar
echo "* And it does..."
echo "-----------------------------------------------------------------"
echo

# Now we'll clone repo1
git clone $homebase/repo1 cloned

echo
echo "------------------------------------------------------------------"
echo "* We might expect cloned/repo2/bar to exist and contain 'bai':"
ls -al cloned/repo2
echo "* But it does not..."
echo "------------------------------------------------------------------"
echo

# Until we explicitly do a submodule update
pushd cloned && git submodule update --init && popd

echo
echo "------------------------------------------------------------------"
echo "* Now we can rest easy..."
ls -al cloned/repo2
echo "------------------------------------------------------------------"
echo

# A concern might be, for openshift, that if you perform a
#   git submodule update --init
# on each push, it might break other users that aren't using submodules, or be
# cumbersome, or slow...  Here if we do a submodule update on a repo that has
# no submodules (repo2 itself), we receive no error messages and it terminates
# rather quickly.

pushd repo2 && git submodule update --init && popd  # (nothing happened)
