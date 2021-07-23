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

The [.github/workflows/my-github-actions.yml][ga], intended to explore what the
Github Actions environment looks and behaves like, looks like this:

[ga]:
    https://github.com/coolaj86/explore-github-actions/blob/master/.github/workflows/my-github-actions.yml

```yaml
name: GitHub Actions Demo
on: [push]
jobs:
    Explore-GitHub-Actions:
        runs-on: ubuntu-20.04
        # Demo is set up in Settings > Environments for Encrypted Secrets
        environment: Demo
        env:
            MY_PUBLIC_ENV: 'Hello, World!'
            MY_DEMO_SECRET: ${{ secrets.MY_DEMO_SECRET }}
        steps:
            - run:
                  echo "🎉 ${{ github.event_name }} on 🐧 ${{ runner.os }} for
                  🔎 ${{ github.repository }}#${{ github.ref }}"
            - name: Check out repository code
              uses: actions/checkout@v2
            - run: echo "💡 Ready!"
            - name: 🖥️ Check where we are...
              run: |
                  echo Home: "${HOME}"
                  echo CWD: "$(pwd)"
                  ls . > cwd.txt
                  ls ${{ github.workspace }} > workspace.txt
            - name: Check which commands are installed...
              run: |
                  ls /bin > bin.txt
                  ls /usr/bin > usr-bin.txt
                  ls /usr/local/bin || true > usr-local-bin.txt
                  ls ~/.local/bin || true > home-local-bin.txt
            - name: Check the PATH...
              run: |
                  cat "${GITHUB_PATH}" > github-path.txt
                  echo "${PATH}" > path.txt
            - name: Webi Installs and PATH Updates
              run: |
                  curl -sS https://webinstall.dev/ | bash
                  echo "${HOME}/.local/bin" >> $GITHUB_PATH
                  curl -sS https://webinstall.dev/node@14 | bash
                  echo "${HOME}/.local/opt/node/bin" >> $GITHUB_PATH
                  curl -sS https://webinstall.dev/hugo | bash
            - name: Verify Webi Installs
              run: |
                  node --version
                  hugo version
            - name: Run the build!
              run: bash ./scripts/build.sh
            - name: Add changes, if any
              run: |
                  if [[ $(git diff --stat) != '' ]]; then
                    git config --global user.name 'Github Actions'
                    git config --global user.email 'github-actions@users.noreply.github.com'
                    git add *.txt
                    git commit -m "update bins list" || true
                    git push
                  fi
            - run: echo "🍏 This job's status is ${{ job.status }}."
```

Aside from the `PATH` and `ENV` exports, this probably could have all run as a
bash script from `./scripts`.

In fact, that probably could have worked too just using normal `export`, but
then it may not be available in other `run` blocks.

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
