#!bin/bash

sudo touch hosts.txt
sudo touch networks.txt

sudo chmod 777 hosts.txt
sudo chmod 777 networks.txt 

ip_addresses=$(hostname -I)


if [[ -z "$ip_addresses" ]]; then
  echo "Failed to retrieve IP addresses."
  exit 1
fi

# Convert IP addresses to networks and summarize
networks=()

for ip_address in $ip_addresses; do
  network=$(ipcalc -n "$ip_address" | awk '/Network:/{print $2}')
  networks+=("$network")
done

# Sort and remove duplicates from networks

summarized_networks=$(printf "%s\n" "${networks[@]}" | sort -u)

# Save the summarized networks to the output file

printf "%s\n" "${summarized_networks[@]}" > "./networks.txt"

# Run nmap command

nmap -sn -iL "./networks.txt" -oG - | awk '/Status: Up/{print $2}' > "./hosts.txt"

sudo docker-compose -f docker-compose.yml -p greenbone-community-edition pull

sudo mkdir -p /tmp/gvm/gvmd
sudo chmod -R 777 /tmp/gvm
sudo chmod -R 777 /var/lib/gvm
sudo chown -R root:root /tmp/gvm
sudo chmod 777 /tmp/gvm/gvmd/gvmd.sock 


sudo docker-compose -f docker-compose.yml -p greenbone-community-edition up -d

sudo gvm-feed-update

gvm-script --version


file="hosts.txt"


if [ ! -f "$file" ]; then
    echo "File not found!"
    exit 1
fi

# Read each line in the file
while IFS= read -r line; do
    
	sudo touch "raportFor$line.pdf"
	sudo chmod 777 "raportFor$line.pdf"
	gvm-script --gmp-username admin --gmp-password admin socket --socketpath /tmp/gvm/gvmd/gvmd.sock raportToPdf.py $(gvm-script --gmp-username admin --gmp-password admin socket --socketpath /tmp/gvm/gvmd/gvmd.sock scan.py $line 4a4717fe-57d2-11e1-9a26-406186ea4fc5) raportFor$line.pdf
	
done < "$file"

for file in raportFor*.pdf; do
  if [ -f "$file" ]; then  # Check if the file exists
    # Perform actions on the file here
    python3 emailsend.py JanWalczak.1515@gmail.com file
    # Add your desired actions or commands for the file here
  fi
done


sudo docker-compose -f docker-compose.yml -p greenbone-community-edition down -v
