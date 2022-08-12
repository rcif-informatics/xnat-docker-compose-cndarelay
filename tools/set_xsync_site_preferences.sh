#!/bin/bash

curl -s -k -n -X POST "https://localhost/xapi/xsyncSitePreferences" -H "accept: */*" -H "Content-Type: text/plain" -d "{ \"tokenRefreshInterval\": \"10 hours\", \"syncRetryCount\": \"2\", \"syncRetryInterval\": \"2 hours\"}"

curl -s -k -n -X POST "https://localhost/xapi/xsyncSitePreferences/aspera" -H "accept: */*" -H "Content-Type: application/json" -d "{ \"asperaNodeUrl\": \"asp-connect1.wustl.edu\", \"asperaNodeUser\": \"xnat\", \"privateKey\": \"/root/.ssh/ccfrelay-ecdsa-key\", \"destinationDirectory\": \"/data/intradb/inbox/xar/\", \"logDirectory\": \"/tmp/\", \"sshPort\": \"33001\", \"udpPort\": \"33001\"}"

curl -s -k -n -X POST "https://localhost/xapi/xsyncSitePreferences/cliTransfer" -H "accept: */*" -H "Content-Type: application/json" -d "{ \"cliTransferScript\": \"/data/xnat/home/relay_tools/xsync_transfer_file\", \"cliTransferHost\": \"asp-connect1.wustl.edu\", \"cliTransferUser\": \"relay-cli\", \"cliTransferRemoteDir\": \"/data/intradb/inbox/xar\", \"cliTransferPrivateKey\": \"/root/.ssh/ccfrelay-ecdsa-key\"}"

