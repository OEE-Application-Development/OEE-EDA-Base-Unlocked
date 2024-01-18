# OEE-EDA-Base-Unlocked

Extensions of EDA package for CSU Online.

## Development

To work on this project in a scratch org:

1. [Set up CumulusCI](https://cumulusci.readthedocs.io/en/latest/tutorial.html)
2. Run `cci flow run dev_org --org dev` to deploy this project.
3. Run `cci org browser dev` to open the org in your browser.


## Environment Setup condensed
Do not have VSCode open -- PATH variable will need updates

-- SFDX
Node.js (for NPM): https://nodejs.org/en/download/
npm install @salesforce/cli --global

-- CCI
https://cumulusci.readthedocs.io/en/latest/get-started.html#on-windows
Download Python: https://www.python.org/downloads/windows/
	- Disable path length limit
	
py -m pip install --user pipx
py -m pipx ensurepath

pipx install cumulusci

-- Windows may not have properly added everything to the path. At any point, may need to close & reopen all command windows.