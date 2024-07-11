#!/usr/bin/env bash

# This converts a dockerfile to a bash script

INPUT=$1
OUTPUT=$2

cp -f $INPUT $OUTPUT

# Add shebang
sed -i '1s|^|#!/usr/bin/env bash\n|' $OUTPUT

# Delete FROM, SHELL, ENTRYPOINT lines
sed -i "/^FROM/d" $OUTPUT
sed -i "/^SHELL/d" $OUTPUT
sed -i "/^ENTRYPOINT/d" $OUTPUT

# Convert ENV and ARG to export
sed -i "s/^ENV\s/export /g" $OUTPUT
sed -i "s/^ARG\s/export /g" $OUTPUT

# Convert WORKDIR to mkdir and insert cd after
sed -i '/^WORKDIR/a cd $WORKDIR\' $OUTPUT
sed -i '/^WORKDIR/a mkdir -p $WORKDIR\' $OUTPUT
sed -i "s/^WORKDIR\s/WORKDIR=~/g" $OUTPUT

# Save working directory and cd back to it after RUN commands
sed -i '/^RUN/i WORKDIR=$PWD' $OUTPUT
sed -i -r '/^RUN.*\\$/!b;:a;n;/(^\s*#|.*\\)/ba;a cd $WORKDIR' $OUTPUT # Add cd after multiline RUN command
sed -i -e '/^RUN/!b' -e '/\\$/b' -e '/cat <<END/b' -e 'a cd \$WORKDIR' $OUTPUT # Add cd after single line RUN command

# Get rid of RUNs
sed -i 's/^RUN\s//g' $OUTPUT
sed -i 's/--mount=[^ ]*//g' $OUTPUT
sed -i '/^\s*\\$/d' $OUTPUT

# Fix opencv fix
sed -i 's|^COPY drone_system/deployment/opencv_fix/CMakeLists.txt|cp drone_system/deployment/opencv_fix/CMakeLists.txt|' $OUTPUT
sed -i 's|^COPY drone_system/deployment/opencv_fix/__multiarray_api.h|sudo cp drone_system/deployment/opencv_fix/__multiarray_api.h|' $OUTPUT

# Delete remaining COPY commands
sed -i "/^COPY/d" $OUTPUT

# Run some commands as superuser
sed -i -r 's/(^|\s)(ln|dpkg-reconfigure|apt-get|apt-key|add-apt-repository)\s/\1sudo \2 /g' $OUTPUT

# Make the output script executable
chmod +x $OUTPUT
