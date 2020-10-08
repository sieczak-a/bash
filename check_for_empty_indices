#!/bin/bash

# created by AS 2020
# scirpt checks size of primary shards of all generated Elasticsearch indices
# when size is less than 50Mb it could mean that data is not beeing sent to Logstash or Logstash has crashed


today=$(date +%F | tr - .)

esEndpoint=$IP # ip address of elasticsearch instance
esPort=$PORT # port of elasticsearch instance

list=$(curl -s "$esEndpoint:$esPort/_cat/indices?&index=*-${today}" | awk '{print $3}' | awk '!(/^\./)')
declare -a my_array

for i in $list
do
    a=$(curl -s "$esEndpoint:$esPort/$i/_stats"| jq ."_all"."primaries"."store" | awk '{print $2}') # jq is a lightweight and flexible command-line JSON processor

    if [ "$a" -ge 0 ] && [ "$a" -le 50000000 ]
    then
        my_array+=("$i")
    fi
done

if [ ${#my_array[@]} -eq 0 ]; then
    echo "No empty indices, OK"
    exit 0
else
    echo "Indices which have less than 50Mb: ${my_array[*]}"
    exit 2
fi
