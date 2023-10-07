#!/bin/bash


#If you would like to see debug messagesm uncomment the following line
#set -x

echo "Install dependencies....."


sudo apt-get update;
sudo apt-get install zenity;
sudo apt-get -q install jq -y;
sudo apt -q install unzip -y;


#PASSWORD=$(zenity --password --width=500 --title="Please enter your SUDO password")
#if [ ! -z "$PASSWORD" ]; then
#    #echo "Your password: $PASSWORD"
        #Elevate the user to admin
#        pw=$(echo $PASSWORD | cut -d'|' -f1);
        #TMP=$(echo "${pw}" | sudo -Sv);
	#echo $TMP
#fi	

(
	echo 1
	echo "# Setting up environment vatiables for AYA installation.."
	sleep 2
	aya_home=$(zenity --entry --width 500 --title "AYA Home" --text "AYA HOME DIRECTORY" --entry-text="/opt/aya");
	if [ $? -ne 0 ]; then
		exit 1;
	fi

	cosmovisor_logfile=${aya_home}/logs/cosmovisor.log
	sentry_setup_json=${aya_home}/sentry.json
	bootstrap_node=true

	echo 2
	echo "# Checking for AYA installation"
	if [ -d ${aya_home} ]; then 

		$(zenity --question --title "Question" --width 500 --text "An existing Aya installation may already exists in the directory you selected \n Continue?");
	fi


	if [ $? -eq 0 ]; then



		sudo rm -rf ${aya_home};
		sudo systemctl stop cosmovisor
		sudo systemctl disable cosmovisor
		kill -9 $(ps -ef | grep -w '/opt/aya/cosmovisor/cosmovisor run start'|awk 'NR==1{print $2}')
		kill -9 $(ps -ef | grep -w '/opt/aya/cosmovisor/genesis/bin/ayad start'|awk 'NR==1{print $2}')
	
		echo 3
		echo "# Please confirm  Chain ID"
		
		CHAIN_ID=$(zenity --entry --width 500 --title "AYA CHAIN ID" --text "AYA Chain ID" --entry-text="aya_preview_501");
		if [ $? -ne 0 ]; then
			exit 1;
		fi

		echo 4
		echo "# Please provide  Moniker name"
		moniker=$(zenity --entry --width 500 --title "MONIKER" --text "moniker name");
		if [ $? -ne 0 ]; then
			exit 1;
		fi

		if [ -z $moniker ]; then
			zenity --error --title "Error Message" --width 500 --height 100 --text "Moniker cannot be empty...EXITING!"
			exit 1;

		fi	

		echo 5
		echo "# Starting Installation..."

		zenity --info --title "Info Message" --width 500 --height 200 --text "Starting installtion with following directories...\n\n\n aya_home=${aya_home} \n cosmovisor_logfile=${cosmovisor_logfile} \n sentry_setup_json=${sentry_setup_json} \n bootstrap_node=${bootstrap_node}"		

		if [ $? -ne 0 ]; then
			exit 1;
		fi

		echo 6
		echo "# creating installation directory for Aya ..." 
		#TMP=$(echo "${pw}" | sudo -S mkdir -p ${aya_home});
		sudo mkdir -p ${aya_home};
		if [ $? -ne 0 ]; then
			zenity --error --title "Error Message" --width 500 --height 100 --text "Fatal: Could not create ${aya_home} directory"
			exit 1;
		fi

		#TMP=$(echo "${pw}" | sudo -S chown "${USER}:${USER}" ${aya_home});
		sudo chown "${USER}:${USER}" ${aya_home};
		if [ $? -ne 0 ]; then
			zenity --error --title "Error Message" --width 500 --height 100 --text "Fatal: could not change ownersip on ${aya_home} directory"
			exit 1;
		fi

		#TMP=$(echo "${pw}" |sudo -S mkdir -p ${aya_home}/cosmovisor/genesis/bin)
		mkdir -p ${aya_home}/cosmovisor/genesis/bin
		if [ $? -ne 0 ]; then
			zenity --error --title "Error Message" --width 500 --height 100 --text "Fatal: Could not create ${aya_home}/cosmovisor/genesis/bin directory"
			exit 1;
		fi

		#TMP=$(echo "${pw}" |sudo -S mkdir -p ${aya_home}/backup)
		mkdir -p ${aya_home}/backup
		if [ $? -ne 0 ]; then
			zenity --error --title "Error Message" --width 500 --height 100 --text "Fatal: Could not create ${aya_home}/backup directory"
			exit 1;
		fi

		#TMP=$(echo "${pw}" |sudo -S mkdir -p ${aya_home}/logs)
		mkdir -p ${aya_home}/logs
		if [ $? -ne 0 ]; then
			zenity --error --title "Error Message" --width 500 --height 100 --text "Fatal: Could not create ${aya_home}/logs directory"
			exit 1;
		fi

		#TMP=$(echo "${pw}" |sudo -S mkdir -p ${aya_home}/config)
		mkdir -p ${aya_home}/config
		if [ $? -ne 0 ]; then
			zenity --error --title "Error Message" --width 500 --height 100 --text "Fatal: Could not create ${aya_home}/config directory"
			exit 1;
		fi


		echo 10
		echo "# Fetching  necessary files......" 


		if [ -d ~/earthnode_installer ]; then 
			rm -rf ~/earthnode_installer
		fi

		mkdir ~/earthnode_installer
		cd ~/earthnode_installer

		install_file=$(zenity --entry --width 500 --title "Repository file location" --text "Confirm the files that are being fetched..." --entry-text="https://github.com/max-hontar/aya-preview-binaries/releases/download/v0.4.1/aya_preview_501_installer_2023_09_04.zip");
		if [ $? -ne 0 ]; then
			exit 1;
		fi

		wget ${install_file}
		if [ $? -ne 0 ]; then

			zenity --error --title "Error Message" --width 500 --height 100 --text "Fatal: Could not download installation files...exiting"
			exit 1;
		fi
		unzip aya_preview_501_installer_2023_09_04.zip
		rm aya_preview_501_installer_2023_09_04.zip

		echo 11
		echo "# Checking for checksum"
		#sha256sum ayad cosmovisor

		#zenity --info --title "Info Message" --width 500 --height 200 --text="Please verify checksum...\n\n $(cat release_checksums)"
		zenity --info --title "Info Message" --width 500 --height 200 --text="Please verify checksum...\n\n $(sha256sum ayad cosmovisor)"

		if [ $? -ne 0 ]; then
			exit 1;
		fi

		echo 12
		echo "# Copying installation files"
		cp ~/earthnode_installer/ayad "${aya_home}"/cosmovisor/genesis/bin/ayad
		cp ~/earthnode_installer/cosmovisor "${aya_home}"/cosmovisor/cosmovisor		


		echo 13
		echo "# Initialying ayad to populate /opt/aya"
		./ayad init "${moniker}" --chain-id $CHAIN_ID --home ${aya_home}

		echo 14
		echo "# Copying genesis.json file"
		cp ~/earthnode_installer/genesis.json "${aya_home}"/config/genesis.json

		echo 20
		echo "# updating config.toml before running Sentry node for the  first time..."

		old_val_statesync="false"
		old_val_addr_book_strict="true"
		old_val_log_level="info"
		old_val_persistent_peer=""
		old_val_seeds=""

		new_val_statesync="true"
		new_val_addr_book_strict="false"
		new_val_log_level="error"
		new_val_persistent_peer="d7e64a6fc57019d04c989f59c2c643ee1133d99c@peer1-501.worldmobilelabs.com:26656,d1da4b1ad17ea35cf8c1713959b430a95743afcd@peer2-501.worldmobilelabs.com:26656"
		new_val_seeds="7836955a4d42ed85a6adb13ae4f96806ab2fd9b2@peer3-501.worldmobilelabs.com:26656"

		
#		zenity --list  --title="Updating config.toml" --text="config.toml file updates" --column "Param Name" --column "Old Value" --column "New Value"	 \
#						"statesync" 		${old_val_statesync}		${new_val_statesync} 	 \
#						"addr_book_strict" 	${old_val_addr_book_strict}	${new_val_addr_book_strict}		\
#						"log_level"		${old_val_log_level} 		${new_val_log_level}		\
					#	"persistent_peers" 	${old_val_persistent_peer}	${new_val_persistent_peer}	\	
					#	"seeds"			${old_val_seeds}		${new_val_seeds}
#		if [ $? -ne 0 ]; then
#			exit 1;
#		fi

		#zenity --info --title "Info Message" --width 500 --height 200 --text "Paramets that wil be updated in config.toml file...\n\n\n\
      	#					'statesync:'${old_val_statesync}    ${new_val_statesync}\n \
     	#					'addr_book_strict:'${old_val_addr_book_strict}	${new_val_addr_book_strict}	\n	\
	#					'log_level:'		${old_val_log_level} 		${new_val_log_level}	\n 	\
	#					'persistent_peers:' 	${old_val_persistent_peer}	${new_val_persistent_peer}\n 	\	
	#					'seeds:'		${old_val_seeds}		${new_val_seeds}"


	#sample test@test:~$ sed "/two/,/why/ s/why/modified/" file
	#sed "/two/,/${why_val}/ s/${why_val}/modified/" file


		sed -i "/statesync/,/enable/ s/enable = .*/enable = ${new_val_statesync}/" ${aya_home}/config/config.toml
		sed -i "/addr_book_strict/s/addr_book_strict = .*/addr_book_strict = ${new_val_addr_book_strict}/" ${aya_home}/config/config.toml
		sed -i "/log_level/s/log_level = .*/log_level = \"${new_val_log_level}\"/" ${aya_home}/config/config.toml
		sed -i "/persistent_peers/s/persistent_peers = .*/persistent_peers = \"${new_val_persistent_peer}\"/" ${aya_home}/config/config.toml
		sed -i "/seeds/s/seeds = .*/seeds = \"${new_val_seeds}\"/" ${aya_home}/config/config.toml
		

		echo 25
		echo "# trying to capture Public IP address automatically..."

		GRAB_PUBLIC_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)

		if [ -z $GRAB_PUBLIC_IP ]; then
			echo "# Could not capture Public IP address automatically"
			public_ip=$(zenity --entry --width 500 --title "Public IP" --text "ATTENTION: Please make sure you are entering valid Public IP adress captured.. \n DO NOT CHANGE THE NUMBER AFTER \":\"" --entry-text="x.x.x.x:26656");
			if [ $? -ne 0 ]; then
				exit 1;
			fi
		else	
			echo 27
			public_ip=$(zenity --entry --width 500 --title "Public IP" --text "ATTENTION: Please validate the Public IP \n DO NOT CHANGE THE NUMBER AFTER \":\"" --entry-text="${GRAB_PUBLIC_IP}:26656");
			if [ $? -ne 0 ]; then
				exit 1;
			fi
		fi	


		sed -i "/external_address/s/external_address = .*/external_address = \"${public_ip}\"/" ${aya_home}/config/config.toml

		echo 30
		echo "# updating app.toml before running Sentry node for the  first time..."

		new_val_grpc_addr="0.0.0.0:29090"
	       	new_val_minimum_gas_prices="0uswmt"
		new_val_api="true"
		new_val_api_addr="tcp://127.0.0.1:1317"

		sed -i "/\[grpc\]/,/address =/ s/address = .*/address = \"${new_val_grpc_addr}\"/" ${aya_home}/config/app.toml
		sed -i "/minimum-gas-prices =/s/minimum-gas-prices = .*/minimum-gas-prices = \"${new_val_minimum_gas_prices}\"/" ${aya_home}/config/app.toml
		sed -i "/\[api\]/,/enable =/ s/enable = .*/enable = ${new_val_api}/" ${aya_home}/config/app.toml
		#sed -i "/\[api\]/,/address =/ s,address = .*,address = \"${new_val_api_addr}\"," ${aya_home}/config/app.toml
		sed -i "/\[api\]/,/address =/ s|address = .*|address = \"${new_val_api_addr}\"|" ${aya_home}/config/app.toml
		

		echo 35
		echo "# exporting environment variables..."

		export DAEMON_NAME=ayad
		export DAEMON_HOME="${aya_home}"
		export DAEMON_DATA_BACKUP_DIR="${aya_home}"/backup
		export DAEMON_RESTART_AFTER_UPGRADE=true
		export DAEMON_ALLOW_DOWNLOAD_BINARIES=true
		ulimit -Sn 4096


		echo 38
		echo "# Preparing to Update firewall..."


		firewall_port_to_open=26656

read -r -d '' firewall_warning_text <<- EOM
ATTENTION: Please read carefully…
This is the most CRITICAL step in the installation process

In the next step you will see 3 options for firewall selection

*** UFW
*** IP Tables
*** Manual

If you are not sure on Firewall, your safest bet probably will be “IP Tables” selection.
If you are selecting manual, please make sure port number "${firewall_port_to_open}" is opened using TCP protocol.
EOM


		zenity --info --title "Info Message" --width 500 --height 200 --text "$firewall_warning_text";

		Firewall=$(zenity --list --radiolist --title "Firewall Menu" --column "Select" --column "Firewall" FALSE "UFW" FALSE "IP Tables", FALSE "Others(Manual)")	
		if [ ${Firewall} = "UFW" ]; then
			sudo ufw allow from any to any port ${firewall_port_to_open} proto tcp;
		elif [ ${Firewall} = "IP Tables" ]; then	
			sudo iptables -I INPUT -p tcp -m tcp --dport ${peer1_port} -j ACCEPT;
			sudo service iptables save;
		else
			zenity --info --title "Info Message" --width 500 --height 100 --text "Please make sure port number "${firewall_port_to_open}" is opened using TCP protocol.";
		fi

		
		echo 40
		echo "# Starting Consmovisor for the first time..."

		#Additional variables not found in the step by step guide
		peer1_port=26657
		peer2_port=26657

		PEER1="http://peer1-501.worldmobilelabs.com:${peer1_port}"
		PEER2="http://peer2-501.worldmobilelabs.com:${peer2_port}"

		
		
		INTERVAL=15000
		LATEST_HEIGHT=$(curl -s "${PEER1}/block" | jq -r .result.block.header.height)
		BLOCK_HEIGHT=$((($((LATEST_HEIGHT / INTERVAL)) - 1) * INTERVAL + $((INTERVAL / 2))))
		TRUST_HASH=$(curl -s "${PEER1}/block?height=${BLOCK_HEIGHT}" | jq -r .result.block_id.hash)

		# Set available RPC servers (at least two) required for light client snapshot verification
		sed -i -E "s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"${PEER1},${PEER2}\"|" "${aya_home}"/config/config.toml
		# Set "safe" trusted block height
		sed -i -E "s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT|" "${aya_home}"/config/config.toml
		# Set "qsafe" trusted block hash
		sed -i -E "s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" "${aya_home}"/config/config.toml
		# Set trust period, should be ~2/3 unbonding time (3 weeks for preview network)
		sed -i -E "s|^(trust_period[[:space:]]+=[[:space:]]+).*$|\1\"302h0m0s\"|" "${aya_home}"/config/config.toml

		"${aya_home}"/cosmovisor/cosmovisor run start --home ${aya_home} &>>"${cosmovisor_logfile}" &

			
                echo 45
                echo "# Consmovisor started successfully!"

		sleep 3 

                echo 50 
                echo "# Starting Synching proess..."

		cd ~/earthnode_installer
		#catch_up=$(./ayad status | jq -r .SyncInfo.catching_up)
		latest_height_local=$(./ayad status | jq -r .SyncInfo.latest_block_height)
		latest_height_global=$(curl -s "http://peer1-501.worldmobilelabs.com:26657/block" | jq -r .result.block.header.height)
		prev_height_local=0

		if [ -z $latest_height_local ]; then
			zenity --error --title "Error Message" --width 500 --height 100 --text "Fatal: Ayad not running, something went wrong! EXITING...."
			exit 1;
		fi	
		
		#while [ $catch_up = "true" ];
		while [ ${latest_height_local} -lt ${latest_height_global} ];
		do
		
			#calc() { awk "BEGIN{ printf \"%.2f\n\", $* }"; }

                        if [ ${prev_height_local} -eq 0 ] && [ ${latest_height_local} -gt 0 ]; then

				initial_delta=$(awk "BEGIN { printf(\"%.2f\", $latest_height_global - $latest_height_local) }")
			elif  [ $latest_height_local -gt 0 ]; then
				delta=$(awk "BEGIN { printf(\"%.2f\", $latest_height_global - $latest_height_local) }")
				result_division=$(awk "BEGIN { printf(\"%.2f\", $delta / $initial_delta) }")
				result_sub=$(awk "BEGIN { printf(\"%.2f\", 1 - $result_division) }")
				progress=$(awk "BEGIN { printf(\"%.2f\", $result_sub*100) }")

				echo "# Synching...$progress"

			fi 


			prev_height_local="${latest_height_local}"

			latest_height_global=$(curl -s "http://peer1-501.worldmobilelabs.com:26657/block" | jq -r .result.block.header.height)
			latest_height_local=$(./ayad status | jq -r .SyncInfo.latest_block_height)
			echo "still catching up...Block height Local = ${latest_height_local} *** Block height Global =${latest_height_global}"

			sleep 10
			catch_up=$(./ayad status | jq -r .SyncInfo.catching_up)
		done


		#zenity --info --title "Info Message" --width 500 --height 200 --text "blah blah blah...\n\n\n blah blah blah \n blah blah blah \n blah blah blah \n blah blah blah";

                echo 70 
                echo "# Cleaning up config.toml and app.toml"
		
		sed -i "/statesync/,/enable/ s/enable = .*/enable = ${old_val_statesync}/" ${aya_home}/config/config.toml

		new_val_snapshot_interval=100
		sed -i "/snapshot-interval =/s/snapshot-interval = .*/snapshot-interval = \"${new_val_snapshot_interval}\"/" ${aya_home}/config/app.toml


                echo 74 
                echo "# Saving all imortant data of the running node..."


		cd ~/earthnode_installer
		# Get the address of the validator
		validator_address=$(./ayad tendermint show-address --home ${aya_home})
		# Use 'jq' to create a JSON object with the 'moniker', 'operator_address' and 'validator_address' fields
		jq --arg key0 'moniker' \
		--arg value0 "$moniker" \
		--arg key1 'validator_address' \
		--arg value1 "$validator_address" \
		'. | .[$key0]=$value0 | .[$key1]=$value1'  \
		<<<'{}' | tee $sentry_setup_json

		sleep 1

		
                echo 78 
                echo "# creating symbolic links....Please enter your SUDO password if system asks"
		sudo ln -s $aya_home/cosmovisor/current/bin/ayad /usr/local/bin/ayad >/dev/null 2>&1
		sudo ln -s $aya_home/cosmovisor/cosmovisor /usr/local/bin/cosmovisor >/dev/null 2>&1

		sleep 1

                echo 80 
                echo "# creating systemd service file...."



sudo tee /etc/systemd/system/cosmovisor.service > /dev/null <<EOF
# Start the 'cosmovisor' daemon
# Create a Systemd service file for the 'cosmovisor' daemon
[Unit]
Description=Aya Node
After=network-online.target

[Service]
User=$USER
# Start the 'cosmovisor' daemon with the 'run start' command and write output to journalctl
ExecStart=$(which cosmovisor) run start --home "${aya_home}"
# Restart the service if it fails
Restart=always
# Restart the service after 3 seconds if it fails
RestartSec=3
# Set the maximum number of file descriptors
LimitNOFILE=4096

# Set environment variables for data backups, automatic downloading of binaries, and automatic restarts after upgrades
Environment="DAEMON_NAME=ayad"
Environment="DAEMON_HOME=${aya_home}"
Environment="DAEMON_DATA_BACKUP_DIR=${aya_home}/backup"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=true"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"

[Install]
# Start the service on system boot
WantedBy=multi-user.target
EOF


		sleep 5

                echo 85 
                echo "# enabling the Cosmovisor service for future uses...."
		# Reload the Systemd daemon
		sudo systemctl daemon-reload
		# Enable the 'cosmovisor' service to start on system boot
		sudo systemctl enable cosmovisor
		#sudo systemctl status cosmovisor.service

		sleep 5

                echo 95 
                echo "# Cleaning up...."


		#ps -ef | grep -w '/opt/aya/cosmovisor/cosmovisor'|awk '{print $2}'| kill -9
		kill -9 $(ps -ef | grep -w '/opt/aya/cosmovisor/cosmovisor run start'|awk 'NR==1{print $2}')
		kill -9 $(ps -ef | grep -w '/opt/aya/cosmovisor/genesis/bin/ayad start'|awk 'NR==1{print $2}')

		sleep 5

		sudo systemctl start cosmovisor.service

		echo 100
		echo "# Package Installation completed!"



	#zenity --text-info --title "Carefully review the information before proceeding" --filename "/etc/hosts"
	fi
) | zenity --width 500 --height 90 --title "Installation Progress Bar" --progress --auto-close

#fi
#pw=$(echo $ENTRY | cut -d'|' -f1)
                #;;
#                TMP=$(echo "${pw}" | sudo -Sv);;

