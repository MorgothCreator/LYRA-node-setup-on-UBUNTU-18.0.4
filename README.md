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
ufw allow 4504
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
Description=Lyra node daemon

[Service]
WorkingDirectory=/home/lyra/lyra/noded
ExecStart=/usr/bin/dotnet /home/lyra/lyra/noded/lyra.noded.dll
Restart=always
# Restart service after 10 seconds if the dotnet service crashes:
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=lyra-noded
User=lyra
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false
# optional mongodb credential if not specified in config*.json
# Environment=LYRA_ApplicationConfiguration__LyraNode__Lyra__Database__DBConnect=mongodb://lexuser:alongpassword@127.0.0.1/lyra

# for mainnet
# Environment=LYRA_NETWORK=mainnet
# Environment=ASPNETCORE_URLS=http://*:5505;https://*:5504
# Environment=ASPNETCORE_HTTPS_PORT=5504

# for testnet
Environment=LYRA_NETWORK=testnet
Environment=ASPNETCORE_URLS=http://*:4505;https://*:4504
Environment=ASPNETCORE_HTTPS_PORT=4504

# if use Engix front end
# Environment=ASPNETCORE_HTTPS_PORT=443

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

### For Mainnet replace all "testnet" words with "mainnet", and ports from 4503 to 5503 and from 4504 to 5504.


# Automatic update:

#### This section assumes that you done all the steps from above and everithing is running OK.

## Now the mainnet script differentiate the released for mainnet from prereleased for testnet checking the minor to be '0', if minor is '0' is a mainnet release, if different is a testnet prerelease.

Both scripts are self protected against empty response by git aplication due to internet glitches or no internet, it will receive an empty response or a response else than expected, will try to downoload from github a release without version string concatenated to the name, that does not exist on github, the script will end up with error that will make no change on the running OS, will try the update procedure in the next six hour + a random delay.

In both scripts, mainnet and testnet the service will write in root home a log with what is the output of the script.

The script assumes that lyranoded run under lyra user account.

Login as root and install mono-utils:

```
apt install mono-utils
```

Copy the update script for testnet or for mainnet to the root home directory:

```
cd ~/
wget https://raw.githubusercontent.com/MorgothCreator/LYRA-node-setup-on-UBUNTU-18.0.4/main/lyra-mainnet-noded-update.sh
```

for mainnet.

```
cd ~/
wget https://raw.githubusercontent.com/MorgothCreator/LYRA-node-setup-on-UBUNTU-18.0.4/main/lyra-testnet-noded-update.sh
```

for testnet.

call crontab setup:

```
crontab -e
```

Choose the desired editor if you not already choosen before, and at the end of the file paste:

```
0 */6 * * * sleep $(( RANDOM \% 21600 ));  /root/lyra-mainnet-noded-update.sh >> /root/lyra-update.log 2>&1
```

This line will call the update script every six hours with a random delay of 0 to 21600 seconds.

This random delay will avoid the situation where all nodes will be shutdown for update and screw up the network.

#### The update script will check on the official lyra repository for an update to appear, if an update is shown will download it, will save the config file to the home directory of lyra user, will decompress the archive, will restore the config file and restart the lyra noded service.

The ".service" files from this repository are only for reference, they will be updated after the official LYRA node is updated, if necessary, so this script's will update only the node, if service files need to be changed, they need to be changed manually by the node operator.


### Donations kindly apreciated:
##### LYR: LCjM28ov1MciT8cd5TmSAiMgiLhSgXhYPUB6mWuqK3ZD8S5axLCtyihxkh5YZFpgbWML7WrC1d7sLLtaCbmT7YqX24ipZo
