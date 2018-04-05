#coding=utf-8
import numpy as np
import jinja2
import matplotlib as plt
import matplotlib.pyplot as plt
import csv #处理csv文件常用的包

data_file="./Data/income_dist.csv"

#自定义打开csv文件的函数
def dataset(path):
    with open(path,'r')as csvfile:
        reader=csv.DictReader(csvfile)
        for row in reader:
            yield row

#查看数据集中有哪些国家
for row in dataset(data_file):
    print row["Country"]

#查看数据集包含哪些年份,set集的使用方法需要总结
print min(set([int(row["Year"]) for row in dataset(data_file)]))

#过滤器中的lanbada函数的作用和意思？
filter(lambda row:row["Country"]=="United States",dataset(data_file))

#绘制数据集相关的视图
def dataset(path,filter_field=None,filter_value=None):
    with open (path,'r') as csvfile:
        reader=csv.DictReader(csvfile)
        if filter_field:
            for row in filter(lambda row:
                              row[filter_field]==filter_value,reader):
                yield row
def main(path):
    data=[(row["Year"],float(row["Average income per tax unit"]))
          for row in dataset(path,"Country","United States")]
    width=0.35
    ind =np.arange(len(data))
    fig=plt.figure()
    ax=plt.subplot(111)
    ax.bar(ind,list(d[1]for d in data))
    ax.set_xticks(np.arange(0,len(data),4))
    ax.set_xticklabels(list(d[0] for d in data)[0::4],rotation=45)
    ax.set_ylabel("Income in USD")
    plt.title("U.S. Average Income 1913-2008")
    plt.show()

main(data_file)





