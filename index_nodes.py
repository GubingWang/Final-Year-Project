from py_post import *
import sys
import os
import math

p = post_open("callusform5_job1.t16")
p.moveto(1)
n = p.node_scalars()
d="index_nodes.txt"
filename2 = "%s" % (d)
file=open(filename2,"w")
for i in range(0, n):
  file.write("%18s%18s%18s\n" % (i,"    ",p.node_scalar_label(i)))
file.close()
