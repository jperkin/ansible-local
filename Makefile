#
# The idea is that playbooks can be called via make(1) to avoid having to
# remember the exact syntax to ansible-playbook(1) every time.
#
# There are a couple of empty variables that allow passing of common additional
# arguments:
#
#	DIFF		For example DIFF=-CD to perform a dry-run to show diffs
#	LIMIT		For example LIMIT="-l localhost" to limit selected hosts
#
# Each playbook should have a target, and be added to the default rule which is
# to show the list of targets.
#

#
# Set up some useful variables.  If you are running this and are not me, you
# will probably want to comment out the private inventory ;)
#
INVENTORIES=		-i inventory.yml
INVENTORIES+=		-i private/inventory.yml
#
ANSIBLE_PLAYBOOK=	ansible-playbook ${DIFF} ${LIMIT} ${INVENTORIES}
#
# Playbooks should follow the same naming scheme where the target and name of
# the playbook file are identical, so that the target below just works.
#
PLAYBOOKS=		bash config ssh

#
# This target should be kept first to be the default.  Don't push anything
# unless specifically requested to.
#
show-targets:
	@echo "Available push targets:"
	@echo ""
	@echo "	make world	Push everything everywhere"
	@echo "	make bash	Push bash configuration files"
	@echo "	make config	Push misc configuration files"
	@echo "	make ssh	Push ssh configuration files"
	@echo ""
	@echo "Available show targets:"
	@echo ""
	@echo "	make list-hosts		List available hosts"
	@echo "	make list-tags		List available tags"
	@echo "	make list-tasks		List available tasks"
	@echo "	make show-targets	Show this help message"
	@echo ""
	@echo "Supported variables:"
	@echo ""
	@echo "	DIFF	For example DIFF=-CD for a dry-run with diffs"
	@echo "	LIMIT	For example LIMIT='-l host' to push only to host"
	@echo ""
	@echo "Examples:"
	@echo ""
	@echo "	# See what changes for all tasks would be made to localhost"
	@echo "	make DIFF=-CD LIMIT='-l localhost' all"
	@echo ""
	@echo "	# Edit ~/.tmux.conf then push just that everywhere"
	@echo "	vi playbooks/config/tmux.conf"
	@echo "	make LIMIT='-t tmux' config"
	@echo ""

#
# The world target is kept separate so that the list-* targets can just glob
# inside the playbooks directories and not end up with duplicate items.
#
.PHONY: world
world:
	@playbooks="$@.yml"; \
	if [ -f private/$@.yml ]; then \
		playbooks="$${playbooks} private/$@.yml"; \
	fi; \
	echo "Running \"${ANSIBLE_PLAYBOOK} $${playbooks}\""; \
	${ANSIBLE_PLAYBOOK} $${playbooks}

.PHONY: ${PLAYBOOKS}
${PLAYBOOKS}:
	@playbooks="playbooks/$@.yml"; \
	if [ -f private/playbooks/$@.yml ]; then \
		playbooks="$${playbooks} private/playbooks/$@.yml"; \
	fi; \
	echo "Running \"${ANSIBLE_PLAYBOOK} $${playbooks}\""; \
	${ANSIBLE_PLAYBOOK} $${playbooks}

.PHONY: list-hosts list-tags list-tasks
list-hosts list-tags list-tasks:
	${ANSIBLE_PLAYBOOK} --$@ playbooks/*.yml private/playbooks/*.yml
