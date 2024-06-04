# Solidity Template (for Forge) [![Github Actions][gha-badge]][gha] [![Branch coverage badge description][branch-coverage-badge-icon]][coverage_report_link_local] [![Foundry][foundry-badge]][foundry] [![License: MIT][license-badge]][license]

<!-- [![Code coverage badge description]
[code-coverage-badge-icon]][coverage_report_link_local] -->

<img src="Images/laser_eyes_3.jpg" alt="A description of the image content"
style="display:block;float:none;margin-left:auto;margin-right:auto;width:50%">

This is a template for Solidity development aimed at the strictest quality
compliance settings, with:

- Dedicated Slither & SolHint pre-commit configs for `src/` and `test/` files.
- Automatic code coverage badge that is computed by GitHub CI.
- Fuzz testing example.
- Fuzz run logging. (This feature is not yet natively supported (as
  of 2024-06-04) so I built a hacky workaround).
- Code/Branch coverage using LCOV.
- Automatically generated documentation.

To start your own Solidity project, just fork it and start building.

## Deployment Prerequisites

```sh
# Install repository configuration.
sudo snap install bun-js
bun install # install Solhint, Prettier, and other Node.js deps
pre-commit install

# Facilitate branch coverage checks.
sudo apt install lcov

# Install foundry
sudo apt install curl -y
curl -L https://foundry.paradigm.xyz | bash
source ~/.bashrc
foundryup
forge build

# Install SolHint (Solidity style guide linterm with autofix.)
sudo apt install npm -y
sudo npm install nodejs
sudo npm install -g solhint
solhint --version

# Install Slither (smart contract static analyzer).
python3 -m pip install slither-analyzer

# Install prettier
npm install --save-dev --save-exact prettier

# Install pre-commit
pre-commit install
git add -A && pre-commit run --all
```

## Build

Build the contracts:

```sh
bun install # run this once.
forge build
```

(If that does not show that the contracts are compiled/does not work, you
probably have the wrong forge, a snap package for Ubuntu installed. See
[solution](https://ethereum.stackexchange.com/questions/139754/when-i-type-forge-init-force-forge-init)
)

## Clean

Delete the build artifacts and cache directories:

```sh
forge clean
```

## Test

Run the tests:

```sh
clear && forge test -vvv
```

Or to run a single test (function):

```sh
clear && forge test -vvv --match-test testAddTwo
```

The `-vvv` is necessary to display the error messages that you wrote with the
assertions, in the CLI. Otherwise it just says: "test failed".

## Branch Code Coverage Report

Get a test coverage report:

```sh
clear && forge coverage \
 --report lcov --via-ir && genhtml -o report --branch-coverage lcov.info
```

## Gas Usage

Get a gas report:

```sh
forge test --gas-report
```

## Generate PlantUML graph of code

To visualise how the code works you can generate a PlantUML graph of the
contracts using:

```sh
npm link sol2uml --only=production # Install sol2uml
sol2uml src/ --outputFileName docs/code_diagram.svg
```

## Generate documentation

You can create and open the documentation as a website with:

```sh
chmod +x create_docs.sh
./create_docs.sh
```

Or generate the markdown documentation with:`forge doc`.

This will create the `classDiagram.svg` diagram of the code:
![Class Diagram](classDiagram.svg)

## GitHub Actions

This template comes with GitHub Actions pre-configured. Your contracts will be
linted and tested on every push and pull request made to the `main` branch.

You can edit the CI script in
[.github/workflows/ci.yml](./.github/workflows/ci.yml).

To ensure the code coverage badge is updated automatically when you push to
`main`,you could:

- Go [here](https://gist.github.com/) and create a secret gist named
  `<your repo name>_branch_coverage.json`
- Update the .github/workflows/ci.yml and replace this repository name with
  `<your repo name>`
- Go to your GitHub settings>developer settings>tokens>classic>create a new
  personal access token that has the following permissions: `gist`.
- Copy that token (secret) and paste it into:
  `<your repository> > settings > Secrets and variables > Actions`
  `> Repository secrets > New repository secret.` ensure that secret has the
  name: `GIST_SECRET` (and value you just copied).
- Then go to the gist by clicking on it in:
  `https://gist.github.com/<your GitHub username>/`
  which gives you an url like:
  `https://gist.github.com/a-t-0/59ab053717e0ed834dc2b24304edd5c6`
  Copy that url and put it in the `branch-coverage-badge-icon` section at the
  bottom of this Readme file.
  - Also copy that gist ID into the `.github/workflows/ci.yml` (twice).

That should be it, now your repo fork has the ability to push the CI results
into the gist you just created, and load the badge from that position.

## Deploy Locally

Deploy to Anvil, first open another terminal, give it your custom `MNEMONIC` as
an environment variable, and run anvil in it:

````sh
# This is a random generated hash with 0 test eth, and the Ethereum test
# network `ethereum-sepolia`
# [faucet](https://www.alchemy.com/faucets/ethereum-sepolia) keeps saying:
# "complete captcha", without showing the captcha (Add block was disabled).
```sh
export MNEMONIC="pepper habit setup conduct material wagon\
captain liquid ill confirm cube easy iron tackle timber"
````

If you can get the faucet to give you test-ETH, you can use your own MNEMONIC
(see [BIP39 mnemonic](https://iancoleman.io/bip39/).). Luckily foundry provides
a standard test wallet with 1000 ETH in it, which can be used with:

```sh
export MNEMONIC="test test test test test test test test test test test junk"
```

While Anvil runs in the background on another terminal, open a new terminal
and run:

```sh
forge script script/Deploy.s.sol --broadcast --fork-url http://localhost:8545
```

By default, this deploys to the HardHat Chain 31337.

## Deploy to Mainnet

For instructions on how to deploy to a testnet or mainnet, check out the
[Solidity Scripting](https://book.getfoundry.sh/tutorials/solidity-scripting.html)
tutorial.

[branch-coverage-badge-icon]: https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/a-t-0/59ab053717e0ed834dc2b24304edd5c6/raw/Decentralised-Saas-Investment-Protocol_branch_coverage.json
[coverage_report_link_local]: report/index.html
[foundry]: https://getfoundry.sh/
[foundry-badge]: https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg
[gha]: https://github.com/TruCol/foundry-template/actions
[gha-badge]: https://github.com/TruCol/foundry-template/actions/workflows/ci.yml/badge.svg
[license]: https://opensource.org/licenses/MIT
[license-badge]: https://img.shields.io/badge/License-MIT-blue.svg
