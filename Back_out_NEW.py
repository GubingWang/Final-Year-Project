from py_post import *
import sys
import os
import math
import numpy as np
# PUT THE RIGHT T16 FILE UNDERNEATH
p = post_open("callusform5_job1.t16")
nincs = p.increments()
p.extrapolation("linear")
i=0
j=0
icounter=0
datinfo=0
p.moveto(nincs-1)
nelements = p.elements()
bone_forcex,bone_forcey,bone_forcez=p.cbody_force(3)
total_dispx = p.node_scalar(200,0)

SC = [[0 for y in range(nelements)] for x in range(4)]
# SELECT THE RIGHT ELEMENT NUMBERS (first element of interest-1 to last element of interest)
for i in range (152, 1574):
        SC[0][icounter]=i+1
        datX = p.element_scalar(i,32)
        datY = p.element_scalar(i,33)
        datZ = p.element_scalar(i,34)
        datinfoX=0
        datinfoY=0
        datinfoZ=0
        for j in range (0,len(datX)):
                datinfoX = datinfoX + datX[j].value
                datinfoY = datinfoY + datY[j].value
                datinfoZ = datinfoZ + datZ[j].value
        SC[1][icounter] = datinfoX/len(datX)
        SC[2][icounter] = datinfoY/len(datX)
        SC[3][icounter] = datinfoZ/len(datX)
        icounter = icounter+1
results = [[0 for y in range(icounter)] for x in range(4)]

for y in range(0,4):
        for x in range(0,icounter):
                results[y][x]=SC[y][x]

file=open("output.txt","w")
np.savetxt("output.txt", results)
file.close()

file=open("outputSPRING.txt","w")
file.write("%s\t%s\n" %(total_dispx,bone_forcex))
file.close()
