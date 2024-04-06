#!/usr/bin/env python3
import time

test1 = open("test1.scad", "r")

test2 = open("test2.scad", "w")
test2.write("")
test2.close()

for line in test1:
    for char in line:
        test2 = open("test2.scad", "a")
        test2.write(char)
        test2.close()
        time.sleep(0.25)
    time.sleep(0.7)
test1.close()

