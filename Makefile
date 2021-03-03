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
# This target should be kept first to be the default.  Don't push anything
# unless specifically requested to.
#
show-targets:
	@echo "Available targets:"
	@echo ""
	@echo "	make all	Push everything"
	@echo "	make bash	Push bash configuration files"
	@echo "	make config	Push misc configuration files"
	@echo ""
	@echo "To perform a dry-run, pass DIFF=-CD"
	@echo "To limit selected hosts, pass LIMIT='-l <hosts>'"

all:
	${ANSIBLE_PLAYBOOK} playbooks/all.yml

bash:
	@PLAYBOOKS="playbooks/bash.yml"; \
	if [ -f private/playbooks/bash.yml ]; then \
		PLAYBOOKS="$${PLAYBOOKS} private/playbooks/bash.yml"; \
	fi; \
	echo "Running \"${ANSIBLE_PLAYBOOK} $${PLAYBOOKS}\""; \
	${ANSIBLE_PLAYBOOK} $${PLAYBOOKS}

config:
	${ANSIBLE_PLAYBOOK} playbooks/config.yml
