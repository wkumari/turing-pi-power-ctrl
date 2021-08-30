#!/bin/bash

# This small script allows rebooting of a slot (Compute Node) of a
# Turing Pi. 

# Copyright (c) 2021 Warren Kumari <warren@kumari.net>

# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# The Software shall be used for Good, not Evil.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Use the I2C expander to power off a slot
# For some bizarre reason, the slots don't match the bit numbers.
# Bits  : 76543210
# Slots : 5674321x


if [ $# -ne 2 ] ; then
  cat <<EOF

  This powers off the specified slot. 

  It accomplishes this by writing to the I2C bus.

  Args:
     command: One of "off", "on", "reboot"
     slot: A slot number to power off. Careful with 1, that's the master (this) node.

  Usage:
    $0 <command> <slot>

EOF
  exit
fi

command=$(echo "$1" | tr '[:upper:]' '[:lower:]' )

# Note: The mapping of bits to nodes is weird, which is why I
# use a case instead of bit-shifting.
# 0x02 : Node #1 (Master)
# 0x04 : Node #2 (Worker 1)
# 0x08 : Node #3 (Worker 2)
# 0x10 : Node #4 (Worker 3)
# 0x80 : Node #5 (Worker 4)
# 0x40 : Node #6 (Worker 5)
# 0x20 : Node #7 (Worker 6)
case $2 in
    1)
	address="0x02"
	echo "Cowardly refusing to power control the master node..."
	printf '\a'
	exit
	;;
    2)
	address="0x04"
	;;
    3)
	address="0x08"
	;;
    4)
	address="0x10"
	;;
    5)
	address="0x80"
	;;
    6)
	address="0x40"
	;;
    7)
	address="0x20"
	;;
    *)
	echo "Slot must be 1-8"
	exit
    esac
       

case $command in
    off)
	sudo i2cset -m $address -y 1 0x57 0xf2 0x00
	;;
    on)
	sudo i2cset -m $address -y 1 0x57 0xf2 0xff
	;;
    reboot)
	echo "Rebooting slot, give me a second please..."
	sudo i2cset -m $address -y 1 0x57 0xf2 0x00
	sleep 1
        sudo i2cset -m $address -y 1 0x57 0xf2 0xff
	;;
    *)
	echo "Command (first argument must be one of 'off', 'on', or 'reboot' (got $command)"
	;;
    esac
