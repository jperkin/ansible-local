"
" Override lines from the default mail.vim to avoid false positives when spell
" checking mails.  This avoids having to maintain local spell files.
"

"
" If a Subject: line is a reply or a forward then I don't want to spell check
" someone else's text.
"
syn match mailSubject contained contains=@NoSpell
	\ "\v^subject: (re|fwd): .*$" fold

"
" Don't spell check attribution lines otherwise I would need to maintain a
" spell file for every single person I ever reply to.
"
" Obviously this needs to be kept in sync with mutt's $attribution variable,
" it currently matches mutt's default as well as my setting to prefix "* ".
"
syn match mailAttribution contains=@NoSpell
	\ "\v^(\* )?On .* wrote:" fold

"
" Don't spell check my signatures at all.
"
syn region mailSignature keepend contains=@mailLinks,@mailQuoteExps,@NoSpell
	\ start="^--\s$" end="^$" end="^\(> \?\)\+"me=s-1 fold
