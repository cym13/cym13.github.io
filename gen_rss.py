#!/usr/bin/env python3

import time
import xml.dom.minidom

BLOG_URL        = "https://breakpoint.purrfect.fr"
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

def get_titles(nodes):
    for article in nodes:
        yield article.getElementsByTagName("a")[0].childNodes[0].data

def get_descriptions(nodes):
    for article in nodes:
        desc = article.getElementsByTagName("p")[0].childNodes[0].data
        yield ' '.join(desc.splitlines())

def get_links(nodes):
    for article in nodes:
        yield article.getElementsByTagName("a")[0].attributes["href"].value

def pub_date(link):
    import subprocess

    link = link.replace("'", "''")
    return subprocess.getoutput("git log --format=%aD $'"+ link +"' | tail -1")

def parse_items(content):
    dom          = xml.dom.minidom.parseString(content)

    titles       = get_titles(dom.getElementsByTagName("dt"))
    descriptions = get_descriptions(dom.getElementsByTagName("dd"))
    links        = get_links(dom.getElementsByTagName("dt"))

    for title, description, link in zip(titles, descriptions, links):
        yield {"title":        title,
                "description": description,
                "link":        BLOG_URL + "/" + link,
                "pub_date":    pub_date(link)}

def main():
    print(header_template.format(blog_url=BLOG_URL,
                                 last_build_date=LAST_BUILD_DATE))

    for item in parse_items(open("index.html").read()):
        print(item_template.format(**item))

    print(footer_template)


if __name__ == "__main__":
    main()
