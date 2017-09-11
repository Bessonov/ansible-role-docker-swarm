#!/bin/bash

set -eu

NODES="$(cat .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory)"

# mac polyfill
sede="sed -r"
if [ "$(uname -s)" = "Darwin" ]; then
	sede="sed -E"
fi

# avoid questions about fingerprint
SSH_ARGS='-o "StrictHostKeyChecking no"'


function run {
	echo "run config:"
	cat test_hosts
	echo ""

	test_name="$1"
	expected="$2"
	node_id=$(echo "$expected" | grep leader | $sede 's/.+([0-9]+).+/\1/')

	time ansible-playbook --inventory-file=test_hosts --ssh-extra-args="$SSH_ARGS" swarm.yml

	result=$(ansible docker-swarm-test-0$node_id --inventory-file=test_hosts --ssh-extra-args="$SSH_ARGS" --become -m shell -a "docker node ls --format '{% raw %}{{ .Hostname }}|{{ lower .Status }}|{{ lower .Availability }}|{{ lower .ManagerStatus }}{% endraw %}' | sort" | tail -n +2)

	if [[ "$expected" == "$result" ]]; then
		echo -e "$test_name: \e[32mok\e[0m"
	else
		echo -e "$test_name: \e[31mfail!\e[0m"
		echo "config:"
		cat test_hosts
		echo ""
		echo "expected:"
		echo "$expected"
		echo ""
		echo "result:"
		echo "$result"
		exit 1
	fi
}

# basic setup
cat > test_hosts <<EOF
$NODES
[managers]
docker-swarm-test-01

[workers]
docker-swarm-test-02
EOF

expected="swarm-node-01|ready|drain|leader
swarm-node-02|ready|active|"

run "test basic setup" "$expected"

# add more nodes

cat > test_hosts <<EOF
$NODES
[managers]
docker-swarm-test-01
docker-swarm-test-02

[workers]
docker-swarm-test-02
docker-swarm-test-03
EOF

expected="swarm-node-01|ready|drain|leader
swarm-node-02|ready|active|reachable
swarm-node-03|ready|active|"

run "add more nodes" "$expected"

# switch workers and managers
cat > test_hosts <<EOF
$NODES
[managers]
docker-swarm-test-02
docker-swarm-test-03

[workers]
docker-swarm-test-01
docker-swarm-test-02
EOF

expected="swarm-node-01|ready|active|
swarm-node-02|ready|active|leader
swarm-node-03|ready|drain|reachable"

run "switch workers and managers" "$expected"

# switch worker and managers again
cat > test_hosts <<EOF
$NODES
[managers]
docker-swarm-test-01
docker-swarm-test-02

[workers]
docker-swarm-test-02
docker-swarm-test-03
EOF

expected="swarm-node-01|ready|drain|reachable
swarm-node-02|ready|active|leader
swarm-node-03|ready|active|"

run "switch worker and managers again" "$expected"

