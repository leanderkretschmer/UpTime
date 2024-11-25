#!/bin/bash

# Prüfe ob Ansible installiert ist
if ! command -v ansible &> /dev/null; then
    echo "Ansible ist nicht installiert. Installation wird gestartet..."
    sudo apt update
    sudo apt install -y ansible
fi

# Führe Ansible Playbook aus
ansible-playbook -i ansible/inventory.yml ansible/server_setup.yml 