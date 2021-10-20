# How to make a new release (maintainer info)

## Release schedule

The xPack GCC release schedule generally follows the original GNU
[releases](https://gcc.gnu.org/releases.html), but with a
several weeks filter, which means that releases that are shortly
overwritten are skipped. Also initial x.y.0 releases are skipped.

## Prepare the build

Before starting the build, perform some checks and tweaks.

### Check Git

In the `xpack-dev-tools/gcc-xpack` Git repo:

- switch to the `xpack-develop` branch
- if needed, merge the `xpack` branch

No need to add a tag here, it'll be added when the release is created.

### Check the latest upstream release

TODO

### Increase the version

Determine the version (like `11.2.0`) and update the `scripts/VERSION`
file; the format is `11.2.0-1`. The fourth number is the xPack release number
of this version. A fifth number will be added when publishing
the package on the `npm` server.

### Fix possible open issues

Check GitHub issues and pull requests:

- <https://github.com/xpack-dev-tools/gcc-xpack/issues/>

and fix them; assign them to a milestone (like `11.2.0-1`).

### Check `README.md`

Normally `README.md` should not need changes, but better check.
Information related to the new version should not be included here,
but in the version specific release page.

### Update versions in `README` files

- update version in `README-RELEASE.md`
- update version in `README-BUILD.md`
- update version in `README.md`

### Update `CHANGELOG.md`

- open the `CHANGELOG.md` file
- check if all previous fixed issues are in
- add a new entry like _- v11.2.0-1 prepared_
- commit with a message like _prepare v11.2.0-1_

Note: if you missed to update the `CHANGELOG.md` before starting the build,
edit the file and rerun the build, it should take only a few minutes to
recreate the archives with the correct file.

### Update the version specific code

- open the `common-versions-source.sh` file
- add a new `if` with the new version before the existing code

### Update helper

With Sourcetree, go to the helper repo and update to the latest master commit.

### Merge upstream repo

To keep the development repository fork in sync with the upstream GCC
repository, in the `xpack-dev-tools/gcc` Git repo:

- checkout `master`
- merge from `upstream/master`
- checkout `xpack-develop`
- merge `master`
- fix conflicts
- checkout `xpack`
- merge `xpack-develop`

Possibly add a tag here.

## Build

### Development run the build scripts

Before the real build, run a test build on the development machine (`wks`)
or the production machine (`xbbm`):

```sh
sudo rm -rf ~/Work/gcc-*

caffeinate bash ~/Downloads/gcc-xpack.git/scripts/helper/build.sh --develop --osx
```

Similarly on the Intel Linux (`xbbi`):

```sh
bash ~/Downloads/gcc-xpack.git/scripts/helper/build.sh --develop --linux64
bash ~/Downloads/gcc-xpack.git/scripts/helper/build.sh --develop --linux32

bash ~/Downloads/gcc-xpack.git/scripts/helper/build.sh --develop --win64
bash ~/Downloads/gcc-xpack.git/scripts/helper/build.sh --develop --win32
```

And on the Arm Linux (`xbba`):

```sh
bash ~/Downloads/gcc-xpack.git/scripts/helper/build.sh --develop --arm64
bash ~/Downloads/gcc-xpack.git/scripts/helper/build.sh --develop --arm32
```

Work on the scripts until all platforms pass the build.

## Push the build scripts

In this Git repo:

- push the `xpack-develop` branch to GitHub
- possibly push the helper project too

From here it'll be later cloned on the production machines.

## Run the CI build

The automation is provided by GitHub Actions and three self-hosted runners.

Run the `generate-workflows` to re-generate the
GitHub workflow files; commit and push if necessary.

- on the macOS machine (`xbbm`) open ssh sessions to both Linux
machines (`xbbi` and `xbba`):

```sh
caffeinate ssh xbbi

caffeinate ssh xbba
```

Start the runner on all three machines:

```sh
~/actions-runner/run.sh
```

Check that both the project Git and the submodule are pushed to GitHub.

To trigger the GitHub Actions build, use the xPack action:

- `trigger-workflow-build`

This is equivalent to:

```sh
bash ~/Downloads/gcc-xpack.git/scripts/helper/trigger-workflow-build.sh
```

This script requires the `GITHUB_API_DISPATCH_TOKEN` to be present
in the environment.

This command uses the `xpack-develop` branch of this repo.

The builds take almost 9 hours to complete.

The workflow result and logs are available from the
[Actions](https://github.com/xpack-dev-tools/gcc-xpack/actions/) page.

The resulting binaries are available for testing from
[pre-releases/test](https://github.com/xpack-dev-tools/pre-releases/releases/tag/test/).

## Testing

### CI tests

The automation is provided by GitHub Actions.

To trigger the GitHub Actions tests, use the xPack actions:

- `trigger-workflow-test-prime`
- `trigger-workflow-test-docker-linux-intel`
- `trigger-workflow-test-docker-linux-arm`

These are equivalent to:

```sh
bash ~/Downloads/gcc-xpack.git/scripts/helper/tests/trigger-workflow-test-prime.sh
bash ~/Downloads/gcc-xpack.git/scripts/helper/tests/trigger-workflow-test-docker-linux-intel.sh
bash ~/Downloads/gcc-xpack.git/scripts/helper/tests/trigger-workflow-test-docker-linux-arm.sh
```

These scripts require the `GITHUB_API_DISPATCH_TOKEN` to be present
in the environment.

These actions use the `xpack-develop` branch of this repo and the
[pre-releases/test](https://github.com/xpack-dev-tools/pre-releases/releases/tag/test/)
binaries.

The tests results are available from the
[Actions](https://github.com/xpack-dev-tools/gcc-xpack/actions/) page.

Since GitHub Actions provides a single version of macOS, the
multi-version macOS tests run on Travis.

To trigger the Travis test, use the xPack action:

- `trigger-travis-macos`

This is equivalent to:

```sh
bash ~/Downloads/gcc-xpack.git/scripts/helper/tests/trigger-travis-macos.sh
```

This script requires the `TRAVIS_COM_TOKEN` to be present in the environment.

The test results are available from
[travis-ci.com](https://app.travis-ci.com/github/xpack-dev-tools/gcc-xpack/builds/).

### Manual tests

Install the binaries on all platforms.

On GNU/Linux and macOS systems, use:

```sh
.../xpack-gcc-11.2.0-1/bin/gcc --version
gcc (xPack GCC x86_64) 11.2.0
```

On Windows use:

```doscon
...\xpack-gcc-11.2.0-1\bin\gcc --version
gcc (xPack GCC x86_64) 11.2.0
```

## Create a new GitHub pre-release draft

- in `CHANGELOG.md`, add the release date and a message like _- v11.2.0-1 released_
- commit and push the `xpack-develop` branch
- run the xPack action `trigger-workflow-publish-release`

The result is a
[draft pre-release](https://github.com/xpack-dev-tools/gcc-xpack/releases/)
tagged like **v11.2.0-1** (mind the dash in the middle!) and
named like **xPack GCC v11.2.0-1** (mind the dash),
with all binaries attached.

- edit the draft and attach it to the `xpack-develop` branch (important!)

## Prepare a new blog post

Run the xPack action `generate-jekyll-post`; this will leave a file
on the Desktop.

In the `xpack/web-jekyll` GitHub repo:

- select the `develop` branch
- copy the new file to `_posts/releases/gcc`

If any, refer to closed
[issues](https://github.com/xpack-dev-tools/gcc-xpack/issues/).

## Update the preview Web

- commit the `develop` branch of `xpack/web-jekyll` GitHub repo;
  use a message like **xPack GCC v11.2.0-1 released**
- push to GitHub
- wait for the GitHub Pages build to complete
- the preview web is <https://xpack.github.io/web-preview/news/>

## Create the pre-release

- go to the GitHub [releases](https://github.com/xpack-dev-tools/gcc-xpack/releases/) page
- perform the final edits and check if everything is fine
- temporarily fill in the _Continue Reading »_ with the URL of the
  web-preview release
- keep the pre-release button enabled
- publish the release

Note: at this moment the system should send a notification to all clients
watching this project.

## Update package.json binaries

- select the `xpack-develop` branch
- run the xPack action `update-package-binaries`
- open the `package.json` file
- check the `baseUrl:` it should match the file URLs (including the tag/version);
  no terminating `/` is required
- from the release, check the SHA & file names
- compare the SHA sums with those shown by `cat *.sha`
- check the executable names
- commit all changes, use a message like
  `package.json: update urls for 11.2.0-1.1 release` (without `v`)

## Publish on the npmjs.com server

- select the `xpack-develop` branch
- check the latest commits `npm run git-log`
- update `CHANGELOG.md`, add a line like _- v11.2.0-1.1 published on npmjs.com_
- commit with a message like _CHANGELOG: publish npm v11.2.0-1.1_
- `npm pack` and check the content of the archive, which should list
  only the `package.json`, the `README.md`, `LICENSE` and `CHANGELOG.md`;
  possibly adjust `.npmignore`
- `npm version 11.2.0-1.1`; the first 5 numbers are the same as the
  GitHub release; the sixth number is the npm specific version
- push the `xpack-develop` branch to GitHub
- push tags with `git push origin --tags`
- `npm publish --tag next` (use `--access public` when publishing for
  the first time)

After a few moments the version will be visible at:

- <https://www.npmjs.com/package/@xpack-dev-tools/gcc?activeTab=versions>

## Test if the npm binaries can be installed with xpm

Run the xPack action `trigger-workflow-test-xpm`, this
will install the package via `xpm install` on all supported platforms.

The test results are available from
[travis-ci.com](https://app.travis-ci.com/github/xpack-dev-tools/gcc-xpack/builds/).

## Update the repo

- merge `xpack-develop` into `xpack`
- push to GitHub

## Tag the npm package as `latest`

When the release is considered stable, promote it as `latest`:

- `npm dist-tag ls @xpack-dev-tools/gcc`
- `npm dist-tag add @xpack-dev-tools/gcc@11.2.0-1.1 latest`
- `npm dist-tag ls @xpack-dev-tools/gcc`

## Update the Web

- in the `master` branch, merge the `develop` branch
- wait for the GitHub Pages build to complete
- the result is in <https://xpack.github.io/news/>
- remember the post URL, since it must be updated in the release page

## Create the final GitHub release

- go to the GitHub [releases](https://github.com/xpack-dev-tools/gcc-xpack/releases/) page
- check the download counter, it should match the number of tests
- add a link to the Web page `[Continue reading »]()`; use an same blog URL
- remove the _tests only_ notice
- **disable** the **pre-release** button
- click the **Update Release** button

## Share on Twitter

- in a separate browser windows, open [TweetDeck](https://tweetdeck.twitter.com/)
- using the `@xpack_project` account
- paste the release name like **xPack GCC v11.2.0-1 released**
- paste the link to the Web page
  [release](https://xpack.github.io/gcc/releases/)
- click the **Tweet** button

## Remove pre-release binaries

- go to <https://github.com/xpack-dev-tools/pre-releases/releases/tag/test/>
- remove the test binaries
