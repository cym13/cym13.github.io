#!/bin/sh

blogUrl="https://cym13.github.io/"
lastBuildDate="$(date -R)"

header_fmt="$(cat <<EOF
<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0">
<channel>
 <title>Breakpoint</title>
 <description>Stepping through security</description>
 <link>${blogURl}</link>
 <lastBuildDate>${lastBuildDate}</lastBuildDate>
 <pubDate>${lastBuildDate}</pubDate>
 <ttl>7200</ttl>
EOF
)"

cat > rss.xml <<< "$header_fmt"

grep -e dt -e dd index.html |\
while read title_line ; do
  read description_line

  link="$(cut -d '"' -f 2 <<< "$title_line")"
  title="$(sed 's/^.*>\([^<]\+\)<\/a>.*$/\1/' <<< "$title_line")"
  description="$(sed 's/^.*>\([^<]\+\)<\/dd>.*$/\1/' <<< "$description_line")"
  src="$(sed 's/^article/source/;s/html$/rst/' <<< "$link")"
  pubDate="$(date -R -d"@$(stat -c "%Y" "$src")")"

cat >> rss.xml <<EOF
 <item>
   <title>${title}</title>
   <description>${description}</description>
   <link>${blogUrl}${link}</link>
   <pubDate>${pubDate}</pubDate>
 </item>
EOF
done

cat >> rss.xml <<EOF
</channel>
</rss>
EOF
