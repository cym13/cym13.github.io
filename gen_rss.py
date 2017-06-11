#!/usr/bin/env python3

import time
import xml.dom.minidom

BLOG_URL        = "https://cym13.github.io/"
DATE_FORMAT     = "%a, %d %b %Y %H:%M:%S %z"
LAST_BUILD_DATE = time.strftime(DATE_FORMAT)

header_template = """<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0">
<channel>
  <title>Breakpoint</title>
  <description>Stepping through security</description>
  <link>{blog_url}</link>
  <lastBuildDate>{last_build_date}</lastBuildDate>
  <pubDate>{last_build_date}</pubDate>
  <ttl>7200</ttl>
"""

item_template = """
 <item>
   <title>{title}</title>
   <description>{description}</description>
   <link>{link}</link>
   <pubDate>{pub_date}</pubDate>
 </item>
"""

footer_template = """
</channel>
</rss>
"""

def title(article):
    return article.getElementsByTagName("a")[0].childNodes[0].data

def description(article):
    desc =  article.getElementsByTagName("p")[0].childNodes[0].data
    return ''.join(desc.splitlines())

def link(article):
    return article.getElementsByTagName("a")[0].attributes["href"].value

def pub_date(article):
    import os
    return time.strftime(DATE_FORMAT,
                         time.localtime(os.stat(link(article)).st_ctime))

def parse_items(content):
    dom = xml.dom.minidom.parseString(content)
    articles = dom.getElementsByTagName("dl")

    for article in articles:
        yield {"title":        title(article),
                "description": description(article),
                "link":        BLOG_URL + "/" + link(article),
                "pub_date":    pub_date(article)}

def main():
    print(header_template.format(blog_url=BLOG_URL,
                                 last_build_date=LAST_BUILD_DATE))

    for item in parse_items(open("index.html").read()):
        print(item_template.format(**item))

    print(footer_template)


if __name__ == "__main__":
    main()
