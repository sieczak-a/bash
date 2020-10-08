# bash
Bash scripts

*check_for_empty_indices* - scirpt written for OP5 agent (nrpe). It checks size of primary shards of all generated Elasticsearch indices. 
When size of index is less than 50Mb it could mean that data is not beeing sent to Logstash, or Logstash has crashed. OP5 monitoring shows critical alarm.

