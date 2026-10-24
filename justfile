inventory := env("ANSIBLE_INVENTORY", "inventory/hosts")

default:
    @just --list --justfile {{ justfile() }}

bootstrap *args: (run-tags "bootstrap" args)

create-vms vm="" *args:
    just --justfile {{ justfile() }} run-tags create-vms --extra-vars=libvirt_vm_only={{ vm }} {{ args }}

full-upgrade *args:
    just --justfile {{ justfile() }} run-tags role-apt_full_upgrade {{ args }}

reboot *args:
    just --justfile {{ justfile() }} run-tags role-reboot_server --extra-vars=reboot_server_confirmed=true {{ args }}

run-tags tags *args:
    #!/usr/bin/env sh
    cd {{ justfile_directory() }}
    ansible-playbook -i {{ inventory }} setup.yml --tags={{ tags }} {{ args }}
