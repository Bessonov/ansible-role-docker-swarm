Ansible role to setup a docker swarm cluster
============================================

[![Project is](https://img.shields.io/badge/Project%20is-fantastic-ff69b4.svg)](https://github.com/Bessonov/ansible-role-docker-swarm)
[![Build Status](https://travis-ci.org/Bessonov/ansible-role-docker-swarm.svg?branch=master)](https://travis-ci.org/Bessonov/ansible-role-docker-swarm)
[![License](http://img.shields.io/:license-MIT-blue.svg)](https://raw.githubusercontent.com/Bessonov/ansible-role-docker-swarm/master/LICENSE.txt)


This role:
- Bootstrap a cluster
- Manage managers and workers

The execution is based on finite state machine and therefore this role can transform existing cluster in desired state. See caveats and test transformation before execution!


See [ansible docker role](https://galaxy.ansible.com/Bessonov/docker/) for docker installaton.

Requirements
------------

Ansible 2.3 and installed docker.

Caveats
-------

If manager nodes changes, at least one of them should be stay static for every playbook run. For example, to exchange manager-1 with manager-2:
1. Add manager-2 to managers
2. Run playbook
3. Remove manager-1 from managers
4. Run playbook

Demote or remove nodes with playbook:
1. Leave nodes in inventory (see the example below)
2. Run playbook
3. Now you can remove nodes which doesn't participate in cluster from inventory

Example Playbook
----------------

Install role globally with:

    ansible-galaxy install Bessonov.docker-swarm

or locally:

    ansible-galaxy install --roles-path roles Bessonov.docker-swarm

Inventory (you can select any names for the groups, `removed-nodes` is optional for new cluster):

    [managers]
    node-1
    node-2
    node-3

    [workers]
    node-1
    node-3
    node-4

    [removed-nodes]
    node-5
    node-6

Playbook:

    # gather facts about nodes which should be removed or demoted from existing cluster
    - hosts: removed-nodes:workers
      tasks: []

    # docker must be installed before
    # you can use any role for docker installation
    - hosts: managers:workers
      roles:
        - Bessonov.docker

    - hosts: managers
      # docker cli doesn't support concurrent access
      serial: 1
      roles:
        - { role: Bessonov.docker-swarm, swarm_worker_hosts: workers }

          # optional: override default parameters, see `defaults/main.yml`
          swarm_cluster_bootstrap_parameters:
            --advertise-addr: enp0s8

License
-------

The MIT License (MIT)

Copyright (c) 2017, Anton Bessonov

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
