#!/bin/bash

set -e
set -u

echo "Hello, World!"
echo "MY_PUBLIC_ENV=${MY_PUBLIC_ENV:-'(not set)'}"
