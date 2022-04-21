deck1=34166
deck2=34162
curl "https://www.firemind.ch/api/v1/duels.json" -d '{"duel":{"freeform":true,"games_to_play":5,"deck_list1_id":34166,"deck_list2_id":34162,"public":true}}' -X POST \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Host: www.firemind.ch" \
  -H "Authorization: Token token=4fe3925f1751c625cec886108adb2cfc" \
  -H "Cookie: "
