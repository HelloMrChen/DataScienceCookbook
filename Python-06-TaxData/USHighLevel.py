#coding=utf-8
import numpy as np
import jinja2
import matplotlib as plt
import matplotlib.pyplot as plt
import csv

data_file="income_dist.csv"

#过滤出特定的国家
def dataset(path,Country="United States"):
    with open(data_file,'r') as csvfile:
        reader=csv.DictReader(csvfile)
        for row in filter(lambda row:row["Country"]==Country,reader):
            yield row

#创建时间序列
def timeseries(data,column):
    for row in filter(lambda row:row[column],data):
        yield (int(row["Year"]),row[column])

#对matplotlib进行包装，传参进行
def linechart(series,**kwargs):
    fig=plt.figure()
    ax=plt.subplot(111)
    for line in series:
        line=list(line)
        xvals=[v[0] for v in line]
        yvals=[v[1] for v in line]
        ax.plot(xvals,yvals)

    if 'ylabel' in kwargs:
        ax.set_ylabel(kwargs['ylabel'])
    if 'title' in kwargs:
        plt.title(kwargs['title'])

    if'labels'in kwargs:
        ax.legend(kwargs.get('labels'))
    return fig

def percent_income_share(source):
    column={
        "Top 10% income share",
        "Top 5% income share",
        "Top 1% income share",
        "Top 0.5% income share",
        "Top 0.1% income share"
    }
    source=list(dataset(source))

    return linechart([timeseries(source,col) for col in column],
                     labels=column,
                     title="U.S Percentage Income Share",
                     ylabel="Percentage")

# percent_income_share(data_file)
# plt.show()

#计算各个阶层收入的中位数并且作图
def normalizes(data):
    data=list(data)
    norm=np.array(list(d[1] for d in data),dtype="f8")
    mean=norm.mean()
    norm/=mean
    return zip((d[0]for d in data),norm)


def norm_percent_income_share(source):
    column={
        "Top 10% income share",
        "Top 5% income share",
        "Top 1% income share",
        "Top 0.5% income share",
        "Top 0.1% income share"
    }
    source=list(dataset(source))

    return linechart([normalizes(timeseries(source,col)) for col in column],
                     labels=column,
                     title="U.S Percentage Income Share",
                     ylabel="Percentage")

# norm_percent_income_share(data_file)
# plt.show()

#不同收入组的各年平均收入，并且进行绘图
def average_income(source):
    column={
        "Top 10% average income",
        "Top 5% average income",
        "Top 1% average income",
        "Top 0.5% average income",
        "Top 0.1% average income"
    }
    source=list(dataset(source))
    return linechart([timeseries(source,col)for col in column],labels=column,title="U.S Average Income",
                     ylabel="2008 US Dollars")

average_income(data_file)
plt.show()