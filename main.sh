#!/bin/bash

fb_page="https://www.facebook.com/btrframes"
counter_like=0
counter_followers=0
inc_frame=0

body="$(curl -s -H "sec-fetch-site: none" -H "sec-fetch-mode: navigate" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9" -H "Accept-language: en-US,en;q=0.9" -H "User-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36" -H "cookie:sb=Y28FZKqetbbzFTQ2KNDPq5fA" -H "cookie:locale=de_DE" "${fb_page}")"
body_en="$(curl -s -H "sec-fetch-site: none" -H "sec-fetch-mode: navigate" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9" -H "Accept-language: en-US,en;q=0.9" -H "User-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36" -H "cookie:sb=Y28FZKqetbbzFTQ2KNDPq5fA" -H "cookie:locale=en_US" "${fb_page}")"

status="$(sed -E 's_\},\{_}\n{_g' <<< "${body}" | sed -nE 's_\._,_g;s_.*text":"([0-9,.]*) \\u201e[^"]*".*_Likes: \1#_p;s_.*text":"([0-9,.]*) Follower".*_Followers: \1_p')"
ttl_frames="Total of $(sed -nE 's_.*&#x2192\; ([0-9,]*)[^!]*_\1_p' <<< "${body_en}" | head -n 1) frames was successfully posted!!"
rating="Rating · $(sed -nE 's_.*"text":"Rating \\u00b7 ([^"]*)".*_\1_p' <<< "${body_en}" | head -n 1)"
page_name="$(sed -nE 's_.*","name":"([^"]*)","profile\_picture".*_\1_p' <<< "${body_en}" | head -n 1)"
image="$(sed -nE 's_amp;__g;s_.*name="twitter:image" content="([^"]*)".*_\1_p' <<< "${body}" | head -n 1)"
status_like="$(sed -nE 's_,__g;s_.*Likes: ([0-9,]*)#.*_\1_p' <<< "${status}")"
status_followers="$(sed -nE 's_,__g;s_.*Followers: ([0-9,]*).*_\1_p' <<< "${status}")"
curl -sL "${image}" -o temp.jpg

circlelize_image(){
	convert "${1}" \
 	-size "${2}" \
        -gravity Center \
        \( xc:Black \
           -fill White \
           -draw "circle $((${2%x*}/2)) $((${2%x*}/2)) $((${2%x*}/2)) 1" \
           -alpha Copy \
        \) -compose CopyOpacity -composite \
        -trim "${3}"
}

# create facebook logo
convert -size 512x512 xc:none \
	-fill "#333333" -draw "circle $((512/2)) $((512/2)) $((512/2)) 1" \
	-fill "#F9BF3B" \
	-draw "path 'M356,330l11-74h-71v-48q1-40,42-40h32v-63q-34-5-57-5c-60,0-97,36-97,100v56H151v74h65v182h80V330z'" "fblogo.png"

# create banner
circlelize_image "temp.jpg" "960x960" "output.png"
convert output.png \
	\( +clone \
		-background black \
		-shadow 50x50+0+0 \
	\) +swap \
	-background none \
	-layers merge \
	+repage outshadow.png


until [[ "${counter_like}" -eq "${status_like}" ]] && [[ "${counter_followers}" -eq "${status_followers}" ]]; do
	increment_val="$(shuf -i 300-600 -n 1)"
	increment_val2="$(shuf -i 300-600 -n 1)"
	: "$((counter_like+=increment_val))"
	: "$((counter_followers+=increment_val2))"
	: "$((inc_frame+=1))"
	if [[ "${counter_like}" -gt "${status_like}" ]]; then
		counter_like="${status_like}"
	fi
	if [[ "${counter_followers}" -gt "${status_followers}" ]]; then
		counter_followers="${status_followers}"
	fi
	status_composer="$(cat <<-EOF
	Likes: $(sed -E ':L;s=\b([0-9]+)([0-9]{3})\b=\1,\2=g;t L' <<< "${counter_like}")
	Followers: $(sed -E ':L;s=\b([0-9]+)([0-9]{3})\b=\1,\2=g;t L' <<< "${counter_followers}")
	EOF
	)"
	convert -size 1280x480 xc:"#F9BF3B" \
		\( outshadow.png \
			-bordercolor "#2980B9" \
			-border 75 \
			-resize 500x500 \
		\) \
		-geometry +0-20 \
		-composite \
		-gravity west \
		-fill "#333333" -font oswald.ttf -pointsize 68 -interline-spacing "-20" -annotate +600-63 "${status_composer}" -interline-spacing 0  \
		\( assets/star.png \
			-fill "#333333" \
			-colorize 100 \
		\) \
		-geometry +600+75 \
		-composite \
		-pointsize 20 -annotate +600+45 "${ttl_frames}" \
		-pointsize 15 -fill "#333333" -annotate +630+75 "${rating}" \
		\( fblogo.png \
			-resize 20x20 \
		\) \
		-geometry +600+105 \
		-composite \
		\( -stroke "#333333" \
			-strokewidth 2 \
			-draw "line 600,265 1100,265" \
		\) \
		-stroke none -pointsize 15 -annotate +630+105 "${fb_page##*/}" \
		-pointsize 20 -annotate +92+200 "${page_name}" \
		-fill "#F9BF3B" -annotate +93+199 "${page_name}" \
		-append banner_"${inc_frame}".png &
done
wait
convert -dispose none -delay 2 -loop 1$(ls -v banner_*.png) -coalesce banner.gif
mogrify -layers 'optimize' -fuzz 7% -loop 1 banner.gif
rm temp.jpg output.png fblogo.png outshadow.png banner_*.png
