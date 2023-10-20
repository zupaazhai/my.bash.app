#!/bin/bash

#=================================
# Docker PS Viewer and accesst to container
#
# Author: Supachai Wongmoon
#=================================

# Create arrays to store container names and IDs
container_names=()
container_ids=()
container_ports=()

extract_port() {
  local input="$1"
  str_ports=""
  IFS=',' read -ra chunks <<< "$input"
  for chunk in "${chunks[@]}"; do
    chunk=$(echo "$chunk" | tr '-' '\n' | head -n 1)
    IFS=':' read -ra uri <<< "$chunk"
    str_ports="$str_ports${uri[1]},"
  done

  str_ports="${str_ports%?}"
  echo $str_ports
}

while IFS= read -r line; do
  container_names+=("$(echo "$line" | awk '{print $1}')")
  container_ids+=("$(echo "$line" | awk '{print $2}')")
  ports=$(extract_port "$(echo "$line" | awk '{print $3 $4}')" )
  container_ports+=($ports)
done < <(docker ps --format "{{.Names}} {{.ID}} {{.Ports}}" --no-trunc)

# Display a numbered list of containers
echo "Select a container to access:"
for i in "${!container_names[@]}"; do
  echo "[$((i+1))] ${container_names[i]} : ${container_ports[i]}"
done

# Read the user's choice
read -p "Enter the number of the container you want to access: " choice

# Validate the choice
if [[ $choice =~ ^[0-9]+$ && $choice -ge 1 && $choice -le ${#container_names[@]} ]]; then
  selected_container="${container_names[choice-1]}"
  selected_container_id="${container_ids[choice-1]}"
  selected_container_port="${container_ports[choice-1]}"

  # if selected container contains with mysql or db
  if [[ $selected_container =~ .*mysql.* ]] || [[ $selected_container =~ .*db.* ]]; then
    echo ""
    echo "======================================"
    echo "Accessing container: $selected_container with MySQL shell"
    echo "Running on Port : $selected_container_port"
    echo "======================================"
    echo ""
    # Run the shell inside the selected container
    docker exec -it "$selected_container_id" mysql -u root -p
    exit 0
  fi

  echo ""
  echo "======================================"
  echo "Accessing container: $selected_container with Bash shell"
  echo "Running on Port : $selected_container_port"
  echo "======================================"
  echo ""
  # Run the shell inside the selected container
  docker exec -it "$selected_container_id" bash
else
  echo "Invalid choice. Please enter a valid container number."
  exit 1
fi
