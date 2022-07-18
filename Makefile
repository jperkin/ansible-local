#
# The idea is that playbooks can be called via make(1) to avoid having to
# remember the exact syntax to ansible-playbook(1) every time.
#
# There are a couple of empty variables that allow passing of common additional
# arguments:
#
#	DIFF		For example DIFF=-CD to perform a dry-run to show diffs
#	LIMIT		For example LIMIT="-l roobarb" to limit selected hosts
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
PLAYBOOKS=		bash config mutt ssh vim

#
# Push by host
#
HOSTS=			roobarb

#
# Per-playbook tags, these allow creating simple shortcut targets.
#
TAGS_bash=	bash_aliases bash_private bash_profile bash_prompt bashrc
TAGS_config=	cvs dircolors ex hushlogin inputrc screen tmux
TAGS_mutt=	mailcap mutt_colours mutt_hooks mutt_sigs muttrc urlview
TAGS_ssh=	authorized_keys known_hosts ssh_config
TAGS_vim=	vim_colours vim_syntax vimrc
TAGS=		${TAGS_bash} ${TAGS_config} ${TAGS_mutt} ${TAGS_ssh} ${TAGS_vim}

#
# This target should be kept first to be the default.  Don't push anything
# unless specifically requested to.
#
help:
	@echo "Available push targets:"
	@echo ""
	@echo "	make world	Push everything everywhere"
	@echo "	make bash	Push bash configuration files"
	@echo "	make config	Push misc configuration files"
	@echo "	make mutt	Push mutt configuration files"
	@echo "	make ssh	Push ssh configuration files"
	@echo "	make vim	Push vim configuration files"
	@echo ""
	@echo "Available show targets:"
	@echo ""
	@echo "	make list-hosts		List available hosts"
	@echo "	make list-tags		List available tags"
	@echo "	make list-tasks		List available tasks"
	@echo "	make help		Show this help message"
	@echo ""
	@echo "Supported variables:"
	@echo ""
	@echo "	DIFF	For example DIFF=-CD for a dry-run with diffs"
	@echo "	LIMIT	For example LIMIT='-l host' to push only to host"
	@echo ""
	@echo "Examples:"
	@echo ""
	@echo "	# See what changes for all tasks would be made to roobarb"
	@echo "	make DIFF=-CD LIMIT='-l roobarb' all"
	@echo ""
	@echo "	# Edit ~/.tmux.conf then push that everywhere except roobarb"
	@echo "	vi playbooks/config/tmux.conf"
	@echo "	make LIMIT='-l all:!roobarb -t tmux' config"
	@echo ""
	@echo "	# Run a temporary command across all hosts"
	@echo "	ansible -i inventory.yml all -a 'rm -f .bash_history'"

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

#
# Run all tasks within a specific playbook.
#
.PHONY: ${PLAYBOOKS}
${PLAYBOOKS}:
	@playbooks="playbooks/$@.yml"; \
	if [ -f private/playbooks/$@.yml ]; then \
		playbooks="$${playbooks} private/playbooks/$@.yml"; \
	fi; \
	echo "Running \"${ANSIBLE_PLAYBOOK} $${playbooks}\""; \
	${ANSIBLE_PLAYBOOK} $${playbooks}

.PHONY: ${HOSTS}
${HOSTS}:
	${ANSIBLE_PLAYBOOK} -l $@ playbooks/*.yml private/playbooks/*.yml

#
# Run specific tags within its associated playbook.
#
.PHONY: ${TAGS}
${TAGS_bash}: playbooks/bash.yml private/playbooks/bash.yml
${TAGS_config}: playbooks/config.yml private/playbooks/config.yml
${TAGS_mutt}: playbooks/mutt.yml private/playbooks/mutt.yml
${TAGS_ssh}: playbooks/ssh.yml private/playbooks/ssh.yml
${TAGS_vim}: playbooks/vim.yml private/playbooks/vim.yml

${TAGS}:
	${ANSIBLE_PLAYBOOK} -t $@ $?

.PHONY: list-hosts list-tags list-tasks
list-hosts list-tags list-tasks:
	${ANSIBLE_PLAYBOOK} --$@ playbooks/*.yml private/playbooks/*.yml
