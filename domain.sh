#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 domain"
  exit 1
fi

domain=$1

whois_output=$(whois $domain 2>/dev/null)

if echo "$whois_output" | grep -iq "No match\|not found\|available"; then
  echo "Domain $domain is available"
else
  echo "Domain $domain is registered"
fi

