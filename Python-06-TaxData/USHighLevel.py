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

#with open as函数是python种打开文件较为常用的方法，也可以同时打开多个文件，比如with open(a) as a ,open (b)as b:，参数中的'r'代表只读模式
#csv.DictReader 是将文件读取之后存储为dict格式，然后通过下边的for循环逐行进行读取。
#lambda 是快速定义函数的一种方法，成为匿名函数，不同于def出来的函数，用法为lamda 参数:表达式
#filter 是一个快速筛选函数，用法为filter(判断表达式，可迭代对象)
#yield 即相当于return
#上述代码即为打开指定目录的csv文件，并且筛选出列Country等于Country参数的行来


#创建时间序列
def timeseries(data,column):
    for row in filter(lambda row:row[column],data):
        yield (int(row["Year"]),row[column])
#通过filter与lambda的结合，在data数据集中筛选出column有值的行，并将该行中的Year以及column列返回
#实际该函数用到的时候column 传入的是列名的合集。因为row[] 在[]中本身就可以写多列。


#对matplotlib进行包装，传参进行
def linechart(series,**kwargs):
    fig=plt.figure()
    ax=plt.subplot(111)
    for line in series:
        line=list(line)
        xvals=[v[0] for v in line]
        yvals=[v[1] for v in line]
        ax.plot(xvals,yvals)

#plt.figure 参数中可以设置图形大小，中间可以传参 figuresize=(width,height)
#subplot是添加子图，并且设置子图标号，一般是111或者211 什么的
#[x for x in line ]这种就是符合x in line 的x值返回
#ax.plot即打印图形，在画图函数中，plt.figure,plt.subplot,ax.plot 基本上是固定步骤

    if 'ylabel' in kwargs:
        ax.set_ylabel(kwargs['ylabel'])
    if 'title' in kwargs:
        plt.title(kwargs['title'])

    if'labels'in kwargs:
        ax.legend(kwargs.get('labels'))
    return fig

#在该函数的参数中设置了kwargs类似于参数数组集，如果有label等相关的参数在这个集合中，则取出来进行操作。
#最终函数返回一个设置好的画图对象。

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

#对source做了个类型转换，这个不多说
#调用linechart函数，将源文件数据source传入，然后将5个固定的列名传入，分别画图打印。
#

#计算各个阶层收入的中位数并且作图
def normalizes(data):
    data=list(data)
    norm=np.array(list(d[1] for d in data),dtype="f8")
    mean=norm.mean()
    norm/=mean
    return zip((d[0]for d in data),norm)
#上述函数中d[1],d[0]为何这样用，不太明白
#zip函数即将两组数进行配对输出，比如zip([1,2,3],[4,5,6])=[(1,4),(2,5),(3,6)]  当然也可以反操作zip(*zipped)



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

#堆积图来分析富裕人群
def stackedarea(series,**kwargs):
    fig=plt.figure()
    axe=fig.add_subplot(111)
    fnx=lambda s:np.array(list(v[1] for v in s),dtype="f8")
    yax=np.row_stack(fnx(s) for s in series)
    xax=np.arange(1917,2008)
    polys=axe.stackplot(xax,yax)  #创建子图对象后，调用对象的stackplot绘制箱线图
    axe.margins(0,0)

    if 'ylabels'in kwargs:
        axe.set_ylabel(kwargs['ylabel'])

    if 'labels' in kwargs:
        legendProxies=[]
        for poly in polys:
            legendProxies.append(plt.Rectangle(0,0),1,1,
                                 fc=poly.get_factor()[0])

    axe.legend([legendProxies,kwargs.get('labels')])

    if 'title' in kwargs:
        plt.title(kwargs['title'])

    return fig


#np.arrange 函数arange([start,] stop[, step,], dtype=None) 即产生一个按照起始值和结束值以及步长值进行的数组
#np.array

def income_composition(source):
    column=("Top 10% average income",
        "Top 5% average income",
        "Top 1% average income",
        "Top 0.5% average income",
        "Top 0.1% average income"
    )

    source=list(dataset(source))
    labels=("Salary","Dividends","Internet","Rent","Business")

    return stackedarea([timeseries(source,col)for col in column],labels=labels,title="U.S. Top 10% Income Composition",ylabel="Percentage")

income_composition(data_file)