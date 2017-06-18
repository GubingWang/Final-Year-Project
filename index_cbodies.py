from py_post import *

import sys
import os
import math

p = post_open("callusform5_job1.t16")
p.moveto(0)
n = p.cbodies()
print n
d="index_cbodies.txt"
filename2 = "%s" % (d)
file=open(filename2,"w")
for i in range(0, n):
  d = p.cbody(i)
  file.write("%18s,%18s\n" % (i,d.name))
file.close()
