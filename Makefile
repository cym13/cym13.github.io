
sources  = $(shell ls source/*.rst)
articles = $(subst .rst,.html,$(subst source/,article/,$(sources)))

RST2HTMLOPT = -t --no-doc-title --title=Breakpoint --syntax-highlight=short

all: index.html about.html $(articles) rss.xml

article/%.html: source/%.rst template/article.tpl
	@ if [ -e $@ ] ; then chmod +w $@ ; fi
	rst2html5 $(RST2HTMLOPT) --template template/article.tpl $< $@
	sed -i 's|http://cdn.mathjax.org/mathjax/latest|../resource/mathjax|' $@
	chmod -w $@

%.html: %.rst template/base.tpl
	@ if [ -e $@ ] ; then chmod +w $@ ; fi
	rst2html5 $(RST2HTMLOPT) --template template/base.tpl $< > $@
	chmod -w $@

rss.xml: gen_rss.py index.html $(articles)
	./gen_rss.py > rss.xml

clean:
	find . -iname "*.html" -type f -delete
	find /source -iname "*.bak" -type f -delete
	rm -f rss.xml
