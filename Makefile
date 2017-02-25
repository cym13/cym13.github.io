
articles= \
article/explication_inode.html \
article/exploiting_gource.html \
article/introduction_ed.html \
article/mail_local_tocttou.html \
article/object_system.html \
article/shell_streams_and_redirections.html \
article/strace_who.html \
article/puppy_writeup.html \
article/crypter_writeup.html

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
