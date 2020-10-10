# Lyra node setup on ubuntu 18.0.4 instance

Login as "root".

Creating "lyra" user:
```
useradd -m lyra -s /bin/bash
```
Setup password for "lyra" user:
```
passwd lyra
```

### Installing mongo-db:
1): Install & start writing line by line:

```
wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
vi /etc/apt/sources.list.d/mongodb-org-4.2.list
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
apt-get update
apt-get install -y mongodb-org
systemctl enable mongod
systemctl start mongod
```
2): Check the state of mongo-db:
```
sudo systemctl status mongod
```
The result need to be:
```
● mongod.service - MongoDB Database Server
   Loaded: loaded (/lib/systemd/system/mongod.service; enabled; vendor preset: enabled)
   Active: active (running) since Thu 2020-10-08 10:48:26 UTC; 1 day 11h ago
     Docs: https://docs.mongodb.org/manual
 Main PID: 4668 (mongod)
   CGroup: /system.slice/mongod.service
           └─4668 /usr/bin/mongod --config /etc/mongod.conf
```
3): Connect to mongo-db:
```
mongo
```
A console will open in mongo-db as fallow:
```
lyra@lyra_sn:~$ mongo
MongoDB shell version v4.2.10
connecting to: mongodb://127.0.0.1:27017/?compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx") }
MongoDB server version: 4.2.10
>
```
4): Type:
```
use admin
```
5): Create a new user:
```
db.createUser(
{
user: "aUsernameYouChoose",
pwd: "aPasswordYouChoose",
roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
}
)
```
* Replace "aUsernameYouChoose" with a username.
* Replace "aPasswordYouChoose" with a pasword.

Press ctrl + d to exit mongo-db console.

6): Open the config file for mongo-db:
```
vi /etc/mongod.conf
```
7): Append at the end of file if is not defined already (if is defined and disabled, write enabled instead):
```
security:
  authorization : "enabled"
```
8): Restart mongo-db service:
```
systemctl restart mongod
```
9): Connect to mongo-db with the new account:
```
mongo -u "aUsernameYouChoose" -p "aPasswordYouChoose" --authenticationDatabase "admin"
```
* Replace "aUsernameYouChoose" with a username set at point 5.
* Replace "aPasswordYouChoose" with a pasword set at point 5.

10): Enter the next text to create two new users under your account, line by line:
```
use lyra
db.createUser({user:'lexuser',pwd:'aPasswordNeededInYourNodeConfigFile',roles:[{role:'readWrite',db:'lyra'}]})
use dex
db.createUser({user:'lexuser',pwd:'aPasswordNeededInYourNodeConfigFile',roles:[{role:'readWrite',db:'dex'}]})
```
* Press ctrl + d to exit from mongo-db console.

11): Restart mongo-db server:
```
systemctl restart mongod
```
### Install dotnet core 3.1 LTS:

12): Paste in the terminal:
```
wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update; \
  sudo apt-get install -y apt-transport-https && \
  sudo apt-get update && \
  sudo apt-get install -y dotnet-sdk-3.1
```

### Enable and allow testnet ports on firewall:

13): Write:
```
ufw start
ufw allow 4503
ufw allow 4505
```
14): Switch to the newly created account on ubuntu ("lyra"):
```
su lyra
```

15): Go to home directory of user "lyra":
```
cd ~/
```

### Install LYRA node:

16): Go to https://github.com/LYRA-Block-Lattice/Lyra-Core/releases and copy the link of the latest "lyra.permissionless" package and type in the terminal:
```
wget lyra.permissionless-1.7.8.0.tar.bz2
tar -xjvf lyra.permissionless-1.7.8.0.tar.bz2
```
* "1.7.8.0" is the package version at the date of this tutorial creation.

17): Create a wallet (the name will be "poswallet"):
```
dotnet ~/lyra/cli/lyra.dll --networkid testnet -p webapi -g poswallet
```
* Fallow the given instructions

18): Edit the node config file:
```
vi ~/lyra/noded/config.testnet.json
```
19): The content need to be as fallow:
```
{
  "ApplicationConfiguration": {
    "LyraNode": {
      "Lyra": {
        "NetworkId": "testnet",
        "Database": {
          "DatabaseName": "lyra",
          "DBConnect": "mongodb://lexuser:alongpassword@127.0.0.1/lyra",
          "DexDBConnect": "mongodb://lexuser:alongpassword@127.0.0.1/wizdex"
        },
        "Wallet": {
          "Name": "poswallet",
          "Password": ""
        },
        "FeeAccountId": ""
      }
    },
    "Storage": {
      "Engine": "LevelDBStore"
    },
    "P2P": {
      "Port": 4503,
      "WsPort": 0,
      "WebAPI": 4505
    },
    "UnlockWallet": {
      "Path": "",
      "Password": "",
      "StartConsensus": false,
      "IsActive": false
    },
    "PluginURL": ""
  }
}
```
* Replace "alongpassword" with the password set at point 10.
* Populate the password entered when you create the wallet.

20): backup the config file for cases where you upgrade the node, when upgrading you will overwrite the config file:
```
cp ~/lyra/noded/config.testnet.json ~/
```
* To recover it after node upgrade:

```
cp ~/config.testnet.json ~/lyra/noded/
```

21): Export LYRA_NETWORK variable:
```
export LYRA_NETWORK=testnet
```
22): Create dev certificates:
```
dotnet dev-certs https --clean
dotnet dev-certs https
```
23): Enter the lyra directory:
```
cd ~/lyra/noded
```
24): Start lyra node:
```
dotnet lyra.noded.dll
```
* Wait for synchronisation to finish.
* Press ctrl + c to close the node.

25): Go to home directory of lira user.
```
cd ~/
```

26): Make variable persistent editing bashrc file:
```
vi .bashrc
```
Press "a" to enter edit mode.
With the arrows go to the end of the file and last letter of the row, press enter and append "export LYRA_NETWORK=testnet"
Press escape to exit edit mode.
Write:
```
:wq
```
Will write the changes and exit.

### Run LYRA node as service:

27): Go back to root account in ubuntu:
```
exit
```

28): Create service file for LYRA node:
```
vi /etc/systemd/system/lyra.service
```
29): A new file will be created and opened, append:
```
[Unit]
Description=LYRA node Testnet
After=network-online.target

[Service]
User=lyra
Type=simple
RestartSec=5
WorkingDirectory=/home/lyra/lyra/noded
Restart=always
ExecStart=/usr/bin/dotnet lyra.noded.dll
Environment=LYRA_NETWORK=testnet
Environment=TERM=xterm

[Install]
WantedBy=multi-user.target
```
30): Save and close:
```
:wq
```
31): Enable & start service:
```
systemctl enable lyra.service
systemctl start lyra.service
```
32): Listen to system log all outputs pushed by LYRA node:
```
journalctl -fu lyra.service
```
With ctrl + c you can exit listening.

### For Mainnet replace all "testnet" words with "mainnet", and ports from 4503 to 5503 and from 4505 to 5505.

### Donations kindly apreciated:
##### LYR: LCjM28ov1MciT8cd5TmSAiMgiLhSgXhYPUB6mWuqK3ZD8S5axLCtyihxkh5YZFpgbWML7WrC1d7sLLtaCbmT7YqX24ipZo
