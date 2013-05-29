!/bin/bash

fakes3 -r lib/buckets -p 10001 &
/config/shotgun -o 0.0.0.0 