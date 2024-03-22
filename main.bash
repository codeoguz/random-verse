# Fetch random verse from the Quran

# API endpoint to get a random Quran verse
API_URL="https://api.quran.com/api/v4"

# echo $(curl -s "$API_URL/verses/random")

random_verse_data=$(curl -s "$API_URL/verses/random")
#example {"verse":{"id":661,"verse_number":168,"verse_key":"4:168","hizb_number":11,"rub_el_hizb_number":42,"ruku_number":84,"manzil_number":1,"sajdah_number":null,"page_number":104,"juz_number":6}}

# echo 'https://api.quran.com/api/v4/quran/verses/uthmani_simple?verse_key=$random_verse_data.verse.verse_key'
 
# Get the verse data in JSON format
verse_key=$(echo $random_verse_data | jq -r '.verse.verse_key')
verse_data=$(curl -s "https://api.quran.com/api/v4/quran/verses/uthmani_simple?verse_key=$verse_key")

## Example response:
# {
#   "verses": [
#     {
#       "id": 494,
#       "verse_key": "4:1",
#       "text_uthmani_simple": "يايها الناس اتقوا۟ ربكم الذى خلقكم من نفس وحدة وخلق منها زوجها وبث منهما رجالا كثيرا ونساء واتقوا۟ الله الذى تساءلون به والارحام ان الله كان عليكم رقيبا"
#     }
#   ],
#   "meta": {
#     "filters": {
#       "verse_key": "4:1"
#     }
#   }
# }

translation_data=$(curl -s "https://api.quran.com/api/v4/quran/translations/52?verse_key=$verse_key")

# example
# {"translations":[{"resource_id":52,"text":"Eğer mümin iseniz, Allah'ın helâlinden size ihsan ettiği kâr sizin için daha hayırlıdır. Bununla beraber ben sizin üzerinize gözcü değilim.\""}],"meta":{"translation_name":"Elmalili Hamdi Yazir","author_name":"Elmalili Hamdi Yazir	","filters":{"verse_key":"11:86","resource_id":52}}}



arabic_text=$(printf $verse_data | jq -r '.verses[0].text_uthmani_simple')
translation=$(printf '%s' "$translation_data" | jq -r '.translations[0].text')



# Clear the terminal screen (optional)

# Display the verse with formatting

# make sure ~/.cache/random-verse/ exists
mkdir -p ~/.cache/random-verse


magick -background none -gravity center -pointsize 24 -size 320x \
          pango:"$arabic_text" \
          ~/.cache/random-verse/temp-verse.png

kitty icat --align center ~/.cache/random-verse/temp-verse.png

echo


# Center the text
COLS=$(tput cols)
center_text() {
    local text="$1"
    local text_length=${#text}
    local padding_length=$(((COLS - text_length) / 2))
    printf "%*s%s%*s\n" $padding_length "" "$text" $padding_length ""
}

center_text "$translation"

echo 

center_text "Sure: $(echo $verse_key | cut -d: -f1)"
center_text "Ayet: $(echo $verse_key | cut -d: -f2)"
