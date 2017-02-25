
sources  = $(addprefix source/,$(shell ls source))
articles = $(subst .rst,.html,$(subst source/,article/,$(sources)))

all: index.html about.html $(articles)

article/%.html: source/%.rst
	@ if [ -e $@ ] ; then chmod +w $@ ; fi
	rst2html5 -t --template template/article.tpl $< > $@
	chmod -w $@

%.html: %.rst
	@ if [ -e $@ ] ; then chmod +w $@ ; fi
	rst2html5 -t --template template/base.tpl $< > $@
	chmod -w $@

clean:
	find . -iname "*.html" -type f -delete
