name=sftp

build:
	podman build -t sftp .

run: build
	podman run \
		--name $(name) \
		-p 2222:22 \
		--rm \
		-v sshd_config:/etc/ssh/sshd_config:ro \
		-v ssh_host_ed25519_key:/etc/ssh/ssh_host_ed25519_key:ro \
		-v ssh_host_ed25519_key.pub:/etc/ssh/ssh_host_ed25519_key.pub:ro \
		-v ssh_host_rsa_key:/etc/ssh/ssh_host_rsa_key:ro \
		-v ssh_host_rsa_key.pub:/etc/ssh/ssh_host_rsa_key.pub:ro \
		-v keys/:/keys/:ro \
		-v sftp/:/share/home/ \
		sftp

.PHONY: build run
