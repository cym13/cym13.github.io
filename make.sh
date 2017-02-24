#!/bin/sh
set -e

ls ./source | grep "rst$" | while read line ; do
    rst2html5 -t --template template/article.tpl \
              "source/$line" > "article/${line%.*}.html"
done

rst2html5 -t --template template/base.tpl \
          "index.rst" > "index.html"

rst2html5 -t --template template/base.tpl \
          "about.rst" > "about.html"
