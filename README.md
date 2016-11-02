# SAnsible

This repo is a set of tools to aid with the development of roles in the SAnsible organisation.




## The roles

All roles in SAnsible follow a similiar pattern, however some roles are slightly older than
others so their Makefiles, tests and travis.yml files are somewhat out of date.

In general though the roles follow a standardised pattern.

* Tests are conducted using Vagrant locally and travis for PRs and branches
* Proper YAML syntax should be used everywhere
* Each role has an editorconfig file to ensure proper formating
* The Makefile contains useful targets for running the tests
* Two tags are present in each role: build and configure
* The test.yml playbook uses an additional tag called assert
* The build tag handles installation and things that do not vary per environment
* The configure tag handles config files and other things that vary per environment
* The additional assert tag covers tests and is generally used for local tests and travis tests
* Ansible-lint is used as part of the tests (pip install ansible-lint)
* Variables all have a parent hash, this has the advantage of making it easier to read
the vars, but has the disadvantage of requiring hash behaviour to be set to 'merge'




## Contributing

If you wish to contribute to one of our roles please open an issue in the roles repo first,
then create a branch named with the issue number (eg. GITHUB-1) making sure that you
create your branch from develop.

When you are ready to open a PR please squash all of your commits into one and
ensure that your commit message contains the Github ID in it's title surrounded by
square braces.

Please try to include a descriptive title followed by more detail in the body, eg:

```
[GITHUB-1] Fixes something

A more detailed description of how this PR will close the issue at hand.
```

A good guide on commit messages is [Tim Pope's guide](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html).

Once your PR is opened Travis will test it, if all the tests passed your PR will be
considered for merging.




## Merges and releases

Once a PR is merged into the develop branch Travis will run tests against it, once finished
the develop branch needs to be merged into the master, at the moment this process is
manual and can be done like so:

* Checkout this repo
* Cd into your local checkout of the role that your PR was for
* Run the sansible release script: `bash [PATH TO THIS REPO]/bin/release.sh`

The release script will handle the merge and cut a new release tag for you, note
that you must have write permissions on the roles repo to do this.

Once master is updated Travis will run tests on the master and update the role
in Galaxy.

You can run `./bin/report.sh` to check the status of all sansible role repos.




### Versioning

The sansible release script will automatically increment the patch version by one
when it is run, it will check what the last version is and simply increment it.

In addition to the [semver](http://semver.org/) versions we always have a major
and minor version, eg:

```
v1.0.1
v1.0.2
v1.0.3
v1.0
```

The major.minor tag always points to the same commit as the most recent patch version,
so in this case v1.0 will be at the same commit as v1.0.3. In your Galaxy requirements
file it is recommended that you point to the major.minor version so you automatically
get the latest patch.

If you are introducing new features or breaking changes you should bump the major
or minor version accordingly, to do this you need to create or edit the version file
in the root of the roles repo. The file should be named .version and simply contain
the major and minor version like so:

```
#.version
v1.2
```

When the Sansible release script is executed it will check this file for the major and minor
version and base the release that it cuts on it.




### Troubleshooting

##### Symptom

Despite of running `sansible/bin/release.sh` successfully without errors, the `master` branch points to the wrong commit.

##### Description

On one particular laptop we once observed that the execution of the `sansible/bin/release.sh` script succeeded but in actual fact the remote master branch was not updated by moving the HEAD. While attempting to go through this process manually, `git` showed the following warning.

```
$ git push
warning: push.default is unset; its implicit value has changed in
Git 2.0 from 'matching' to 'simple'. To squelch this message
and maintain the traditional behaviour, use:

  git config --global push.default matching

To squelch this message and adopt the new behaviour now, use:

  git config --global push.default simple
```

This laptop was only recently setup and it had already been used to push commits to remote repositories, however the target branch was usually specified. The weired thing is that with `git 2.0` or higher, `simple` is the default `push.default` option. Therefore it should normally not be required to be configured.

##### Solution

Configure the `push.default` option as the warning outlines. If in doubt, use `git config --global push.default simple`.
