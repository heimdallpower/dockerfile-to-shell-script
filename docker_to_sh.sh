#!/bin/bash

# This converts a docker file to a shell file
# Almost guaranteed to not work with many Docker files, but hey, it works for us

INPUT=$1
# Use the extension of the dockerfile as file name of the output file
filename=$(basename -- "$INPUT")
extension="${filename##*.}"
OUTPUT=install_$extension.sh

cp -f $INPUT $OUTPUT

# Convert FROM, MAINTAINER, VOLUME to comments
sed -i "s/^FROM\s/# FROM /g" $OUTPUT
sed -i "s/^MAINTAINER\s/# MAINTAINER /g" $OUTPUT
sed -i "s/^VOLUME\s/# VOLUME /g" $OUTPUT

# Get rid of RUNs
sed -i "s/^RUN\s//g" $OUTPUT
sed -i 's|^\\$||g' $OUTPUT

# Convert ENVs into EXPORTs
sed -i "s/^ENV\s/export /g" $OUTPUT

# Get rid of EXPOSE todo: open up ports based on these?
sed -i "s/^EXPOSE\s/# EXPOSE /g" $OUTPUT

# Convert ADDs into cp
sed -i "s/^ADD\s/cp /g" $OUTPUT

# Convert ARG to EXPORT
sed -i "s/^ARG\s/export /g" $OUTPUT

# Convert WORKDIR to mkdir and insert cd after
sed -i '/^WORKDIR/a cd \$_' $OUTPUT
sed -i "s/^WORKDIR\s/mkdir -p /g" $OUTPUT

# Convert COPY to cp
sed -i "s/^COPY\s/cp /g" $OUTPUT

# Timestamp
sed -i '1s/^/# Generated by docker_to_sh, for all your shoddy bash script from Dockerfile generation needs. \n/' $OUTPUT
