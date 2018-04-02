
#coding=utf-8
import numpy as np
import jinja2
import matplotlib as plt
import matplotlib.pyplot as plt
import csv

data_file="./Data/income_dist.csv"

dataset=np.recfromcsv(data_file,skip_header=1)

print  dataset.size

names=["Country","year"]
names.extend()