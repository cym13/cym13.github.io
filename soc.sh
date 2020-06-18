#!/bin/bash

# Simple microblogging feature on top of my blog engine

if [ "$1" = "-h" ] || [ "$1" = "--help" ] ; then
    echo "Stream of Consciousness"
    echo
    echo "Usage: soc [TEXT]"
    exit
fi

cd ~/usr/git/cym13.github.io

tmp="$(mktemp --suffix='.rst')"
timestamp=""

function edit() {
    if [ -z "$@" ] ; then
        "$EDITOR" "$tmp"
    else
        echo "$@" > "$tmp"
    fi

    if ! grep -q . "$tmp" ; then
        echo "Nothing to publish"
        exit 0
    fi

    timestamp="$(date)"

    sed -i "1i----\n\n**${timestamp}**\n" "$tmp"
    echo >> "$tmp"
    sed -i "6r $tmp" soc.rst
}

function preview() {
    make
    "$BROWSER" "file://$PWD/soc.html"
}

function update_rss() {
    if [ ! -f soc_rss.xml ] ; then
        cat >soc_rss.xml <<EOF
<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0">
<channel>
  <title>Breakpoint - Stream of Consciousness</title>
  <description>Stream of Consciousness</description>
  <link>https://breakpoint.purrfect.fr/soc.html</link>
  <lastBuildDate>Tue 16 Jun 2020 08:12:21 PM CEST</lastBuildDate>
  <pubDate>Tue 16 Jun 2020 08:12:21 PM CEST</pubDate>
  <ttl>7200</ttl>
</channel>
</rss>
EOF
    fi

    sed -i "/<lastBuildDate>/s/>[^<]*</>$timestamp</" soc_rss.xml
    sed -i "0,/<pubDate>/s/<pubDate>[^<]*</<pubDate>$timestamp</" soc_rss.xml

    tmp_rss="$(mktemp)"

    title="$(sed -n '/^\*\*/s/\*\*//gp' "$tmp" | head -1)"
    description="$(sed '1,4d' "$tmp" | sed 's/</\&lt;/g ; s/>/\&gt;/g')"

    cat >"$tmp_rss" <<EOF
      <item>
        <title>${timestamp}</title>
        <description>${description}</description>
        <link>https://breakpoint.purrfect.fr/soc.html</link>
        <pubDate>${timestamp}</pubDate>
      </item>
EOF

    sed -i "9r $tmp_rss" soc_rss.xml

    rm "$tmp_rss"
}

function publish() {
    read -p "Publish? [y/N] " publish
    if [ "$publish" = "y" ] || [ "$publish" = "Y" ] ; then
        update_rss
        git add soc.rst soc.html soc_rss.xml
        git commit -m "SoC update"
        git push
        return 0
    else
        git checkout soc.rst soc.html
        return 1
    fi
}

function main() {
    edit "$@"
    preview
    publish
    rm "$tmp"
}

main "$@"
