# `nodebb` Salt States

The `nodebb` states were used to try [nodebb](https://nodebb.org/). These are not used on a production server right now and may be outdated.

## Applying states

Install using `salt-ssh '<server-name>' state.sls nodebb` (replace `<server-name>` with the instance name from salt `roster` file).

The salt state does the following:

- install nginx as a proxy
- issue a letencrypt certificate for the server name
- install postfix for sending mails (relay via cebe.cc mail cluster)
- install nodejs and yarn
- install nodebb
- setup nodebb (will print out admin username and password on first run)

You can access nodebb on the server host name, e.g. `https://nodebb.example.com`

Manual configuration steps:

- configure email in NodeBB settings to use `localhost` port `25` smtp server.

### Data import

TODO

Resources:

- https://github.com/NodeBB/NodeBB/issues/2008
- https://github.com/akhoury/nodebb-plugin-import-ipboard
- https://github.com/akhoury/nodebb-plugin-import


### TODO

- configure backup for `/opt/nodebb/public/uploads` and mongodb
- configure yii integration

