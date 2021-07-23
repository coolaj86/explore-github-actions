# explore-github-actions

If you were looking for a way to turn bash scripts into an npm-level of
one-liner, one-thousand dependencies hell, then at first blush Github Actions
would appear to be the ideal [double-clawed hammer][hammer] candidate.

[hammer]: https://blog.codinghorror.com/the-php-singularity/

And indeed it is!

But, it doesn't _have to_ be...

Rather than building scripts that are nested dozens, or hundreds of one-liner
"actions" deep with dozens of lines of metadata for "workflows", you can, in
fact, write them nice and flat-like. Here's how:

## Github Actions, without the Kool-Aid

Create your repository, as per usual:

```bash
mkdir ~/Projects/explore-github-actions
pushd ~/Projects/explore-github-actions
git init
```

And then create an actions folder and file for yourself: \
(the name of the yml file doesn't matter)

```bash
mkdir -p .github/workflows/
touch .github/workflows/my-github-actions.yml
```

And, assuming `ubuntu-20.04` (or `ubuntu-latest`), you end up with a system
that's actually a pretty huge, full Linux distribution.

Almost every tool you can imagine is already installed, and even
`${HOME}/.local/bin` is already in your `$PATH`.

Here's

```yaml
name: Inspect GitHub Actions Environment
on: [push]
jobs:
    Explore-GitHub-Actions:
        runs-on: ubuntu-20.04
        steps:
            - run: echo "🎉 The job was automatically triggered by a ${{ github.event_name }} event."
            - run: echo "🐧 This job is now running on a ${{ runner.os }} server hosted by GitHub!"
            - run: echo "🔎 The name of your branch is ${{ github.ref }} and your repository is ${{ github.repository }}."
            - name: Check out repository code (TODO do this the normal way)
              uses: actions/checkout@v2
            - run: echo "💡 The ${{ github.repository }} repository has been cloned to the runner."
            - run: echo "🖥️ The workflow is now ready to test your code on the runner."
            - name: List files in the repository
              run: |
                  ls .
              run: |
                  ls ${{ github.workspace }}
              run: |
                  rsync --help
              run: |
                  curl --help
                  wget --help
            - run: echo "🍏 This job's status is ${{ job.status }}."
```

## What's Available?

-   curl
-   wget
-   rsync
-   node
-   git

And thousands more. 👀 Check the `*.txt` files in this repo 👆 for the
up-to-date list.

And, of course, you can use [Webi](https://webinstall.dev) with the one caveat
potentially needing to manually add some `PATH`s manually, such as
`echo "$HOME/.local/opt/golang/bin" >> $GITHUB_PATH; echo "${HOME}/go/bin" >> $GITHUB_PATH`
if installing Go.

Check out [actions/virtual-environments/images/linux][linuxes].

[linuxes]:
    https://github.com/actions/virtual-environments/blob/main/images/linux/Ubuntu2004-README.md

## Notes

-   PATH & ENVs
    -   `echo './path/to/bin' >> ${GITHUB_PATH}` replaces `add-path`
    -   `echo "FOO=BAR" >> $GITHUB_ENV` replaces `set-env`
    -   I think those are not evaluated until the start of the next `run` block
-   `GITHUB_TOKEN` is available as a single-use token, immediately invalidated
    after the action runs
-   Tokens for other services are set in `Settings > New repository secret` and
    accessible by the name you set
    -   I trust Github maybe more than I trust facebook... still on the fence as
        to whether or not I like the idea of them having my DO server's SSH
        deploy key...

## Good References

-   [QuickStart for Github Actions](https://docs.github.com/en/actions/quickstart)
    (just a "Hello, World" with echo, but illustrative)
-   [actions/toolkit/commands.md](https://github.com/actions/toolkit/blob/main/docs/commands.md#environment-files) -
    where I finally found the usage of the `GITHUB_*` ENVs
-   [Authentication with `$GITHUB_TOKEN`](https://docs.github.com/en/actions/reference/authentication-in-a-workflow?query=gist)
-   [3rd Party Services with SECRETS](https://docs.github.com/en/actions/reference/encrypted-secrets)
    for SSH_DEPLOY keys, or whatever
