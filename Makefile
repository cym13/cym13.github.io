
sources  = $(shell ls source/*.rst)
articles = $(subst .rst,.html,$(subst source/,article/,$(sources)))

RST2HTMLOPT = -t --no-doc-title --title=Breakpoint --syntax-highlight=short

all: index.html about.html soc.html cve.html $(articles) rss.xml

article/%.html: source/%.rst template/article.tpl
	@ if [ -e $@ ] ; then chmod +w $@ ; fi
	rst2html5 $(RST2HTMLOPT)                  \
		--title "Breakpoint: $$(grep "^\w" $< | head -1)" \
		--template template/article.tpl       \
		$< $@
	sed -i '/<meta name="viewport"/d' $@
	sed -i 's|<s>|<span class="s">|g;s|</s>|</span>|g' $@
	sed -i 's|http://cdn.mathjax.org/mathjax/latest|../resource/mathjax|' $@
	sed -i "s|»PUB_DATE«|$$(git log --format=%aD $$'$@' | tail -1)|" $@
	chmod -w $@

%.html: %.rst template/base.tpl
	@ if [ -e $@ ] ; then chmod +w $@ ; fi
	rst2html5 $(RST2HTMLOPT) --template template/base.tpl $< > $@
	sed -i '/<meta name="viewport"/d' $@
	sed -i 's|<s>|<span class="s">|g;s|</s>|</span>|g' $@
	chmod -w $@

rss.xml: gen_rss.py index.html $(articles)
	./gen_rss.py > rss.xml

clean:
	find . -iname "*.html" -type f -delete
	find ./source -iname "*.bak" -type f -delete
	rm -f rss.xml
