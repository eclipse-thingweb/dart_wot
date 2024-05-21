# Contributing to Eclipse Thingweb

Thanks for your interest in this project. General information
regarding source code management, builds, coding standards, and
more can be found here:

-   https://projects.eclipse.org/projects/iot.thingweb/developer

## Legal Requirements

Thingweb is an [Eclipse IoT](https://iot.eclipse.org) project and as such is governed by the Eclipse Development process.
This process helps us in creating great open source software within a safe legal framework.

Thus, before your contribution can be accepted by the project team, contributors must electronically sign the [Eclipse Contributor Agreement (ECA)](http://www.eclipse.org/legal/ECA.php) and follow these preliminary steps:

-   Obtain an [Eclipse Foundation account](https://accounts.eclipse.org/)
    -   Anyone who currently uses Eclipse Bugzilla or Gerrit systems already has one of those
    -   Newcomers can [create a new account](https://accounts.eclipse.org/user/register?destination=user)
-   Add your GitHub username to your Eclipse Foundation account
    -   ([Log into Eclipse](https://accounts.eclipse.org/))
    -   Go to the _Edit Profile_ tab
    -   Fill in the _GitHub ID_ under _Social Media Links_ and save
-   Sign the [Eclipse Contributor Agreement](http://www.eclipse.org/legal/ECA.php)
    -   ([Log into Eclipse](https://accounts.eclipse.org/))
    -   If the _Status_ entry _Eclipse Contributor Agreement_ has a green checkmark, the ECA is already signed
    -   If not, go to the _Eclipse Contributor Agreement_ tab or follow the corresponding link under _Status_
    -   Fill out the form and sign it electronically
-   Sign-off every commit using the same email address used for your Eclipse account
    -   Set the Git user email address with `git config user.email "<your Eclipse account email>"`
    -   Add the `-s` flag when you make the commit(s), e.g. `git commit -s -m "feat: add support for magic"`
-   Open a [Pull Request](https://github.com/eclipse-thingweb/node-wot/pulls)

For more information, please see the Eclipse Committer Handbook:
https://www.eclipse.org/projects/handbook/#resources-commit

## Release management

`dart_wot` currently uses a semi-automated process for creating new releases.
This involves generating the changelog, bumping the version number, and then
letting GitHub Actions push the new version to pub.dev.

### Changelog generation

For the creation of the changelog, we use [`git-cliff`](https://git-cliff.org/)
which automatically generates a `CHANGELOG.md` file based on the commit history
and the [conventional commit](https://conventionalcommits.org) messages that
have been used.
The changelog is formatted according to the
[Keep a Changelog](https://keepachangelog.com) format via the configuration
options set in `cliff.toml`.

Whenever a new commit is published to the `main` branch, a GitHub Actions
workflow is run to update the changelog and push any changes to a (if needed)
newly created Pull Request that also bumps the version number in the
`pubspec.yaml` file.

### Creating a new release

Preparing a new release currently still involves some manual work.

Once a new release is ready, merge the latest Pull Request for release
preparation.
Then create a corresponding git tag for the release number with the prefix
`v`(e.g., `v1.0.0` for version `1.0.0`).
This can also be done via the GitHub web interface while creating a new release
(where the latest `CHANGELOG.md` entry can be used for the release notes).

When the new tag is pushed to the remote repository on GitHub, a separate
GitHub Actions workflow is then triggered that will push the new version to
the pub.dev package repository, making it available for package users.

## Contact

Contact the project developers via the project's "dev" list.

-   https://dev.eclipse.org/mailman/listinfo/thingweb-dev
