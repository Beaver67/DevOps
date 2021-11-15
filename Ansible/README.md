# Ansible Notes

This readme highlights some common notes and features of Ansible that are used frequently.

Ansible is used to configure the servers (and other resources) by automating the configuration, updates and application deployment.

TODO: This is a work in progress and more configuration and testing needs to be done.

## Common Commands

| Command         | Usage           |
| ------------- |:-------------|
| ansible  < group > -m -ping     | ping a host and confirm connection|
| ansible-playbook < playbook.yml > -i < inventory_file.ini > -l < host_group_name >   | runs the named playbook with the named inventory file, using the host_group_name grouping. For example "ansible-playbook playbook.yml -i dev.ini  -l webservers" runs the playbook for dev webservers.|


## Ansible File Structure

https://charlesreid1.com/wiki/Ansible/Directory_Layout/Details
https://docs.ansible.com/ansible/2.8/user_guide/playbooks_best_practices.html


