#!/bin/bash

body="$(curl -s -H "sec-fetch-site: none" -H "sec-fetch-mode: navigate" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9" -H "Accept-language: en-US,en;q=0.9" -H "User-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36" -H "cookie:sb=Y28FZKqetbbzFTQ2KNDPq5fA" -H "cookie:locale=ja_JP" "https://www.facebook.com/btrframes")"

status="$(printf '%s' "$body" | sed -E 's_\},\{_}\n{_g' | sed -nE 's_.*text":"([0-9,]*) \\u4ef6[^"]*".*_Likes: \1#_p;s_.*text":".*\\u30fc([0-9,]*)\\u4eba".*_Followers: \1_p')"

image="$(printf '%s' "$body" | sed -nE 's_amp;__g;s_.*name="twitter:image" content="([^"]*)".*_\1_p')"
curl -sL "$image" -o temp.jpg

convert -size 800x300 xc:"#7D9CBE" \( temp.jpg -bordercolor "#7D9CBE" -border 75 -resize 300x300 \) -geometry +0+0 -composite -gravity west -fill "#BE4C7D" -fill "#312D2C" -font oswald.ttf -pointsize 68 -annotate +300+0 "${status%#*}${status#*#}" -geometry +100+0 -append banner.jpg

rm temp.jpg
