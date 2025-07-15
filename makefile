.SILENT:

all: make_pdf commit_changes

make_pdf:
	if ! pdflatex -draftmode -halt-on-error -mktex main.tex main.tex > .temp 2>&1; then \
		tail .temp;exit 1;\
	fi
	echo '--------------------------------------------------------------------------'
	echo 'Valid LaTeX, proceeding to create PDF.'
	echo '--------------------------------------------------------------------------'
	texlua scripts/checkcites.lua main.aux | tail -n 12
	echo '--------------------------------------------------------------------------'
	bibtex main > /dev/null
	pdflatex -draftmode -halt-on-error -mktex main.tex main.tex > .temp 2>&1
	pdflatex  main.tex > /dev/null 2>&1
	mv main.pdf thesis.pdf

synopsis:
	if ! pdflatex -draftmode -halt-on-error -mktex synopsis.tex synopsis.tex > .temp 2>&1; then \
		tail .temp;exit 1;\
	fi
	echo '--------------------------------------------------------------------------'
	echo 'Valid LaTeX for synopsis, proceeding to create PDF.'
	echo '--------------------------------------------------------------------------'
	bibtex synopsis > /dev/null
	pdflatex -draftmode -halt-on-error -mktex synopsis.tex synopsis.tex > .temp 2>&1
	pdflatex  synopsis.tex > /dev/null 2>&1
	make clean > /dev/null 2>&1

commit_changes: clean
ifeq ($(m),)
	echo 'PDF created successfully. Skipping commit.'
	echo '--------------------------------------------------------------------------'
else
	git add -A
	git commit -m "$(m)" > /dev/null 2>&1
	git push > /dev/null 2>&1
	echo 'PDF created, changes commited and pushed to remote repository.'
	echo '--------------------------------------------------------------------------'
endif

clean:
	rm -f *.aux
	rm -f *.log
	rm -f *.loc
	rm -f *.soc
	rm -f *.bbl
	rm -f *.blg
	rm -f *.out
	rm -f *.brf
	rm -f *.toc
	rm -f *.lot
	rm -f *.lof
	rm -f *.nlo
	rm -f chapters/*.aux
	rm -f .temp
