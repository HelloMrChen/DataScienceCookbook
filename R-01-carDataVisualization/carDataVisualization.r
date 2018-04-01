# install.packages("plyr")
library(plyr)
# install.packages("ggplot2")
# install.packages("reshape2")
# library(ggplot2)
# library(reshape2)
#cmd+shift+c 注释快捷键


#将文件夹拖进终端中即可
setwd("/Users/gavinchen/我的文档/MBA养成记/2-自我提升/2-数据分析/程序练习/数据科学实战手册/R-01-carDataVisualization")
vehicles<-read.csv("Data/vehicles.csv") #由于设置了工作目录，直接写下一层目录Data即可
head(vehicles)

#给csv中的变量贴上标签
#这里的空格很重要，防止无拆分连续的字符串，这用到了readline、strsplit、docall、rbind 
labels<-do.call(rbind,strsplit(readLines("Data/varlabels.txt")," - "))

#------数据准备及查看详情
summary(vehicles)
nrow(vehicles)
ncol(vehicles)
names(vehicles)

length(unique(vehicles[,"year"]))
vehicles[,"year"] #取数据框中的某一列
length(unique(vehicles$year))

min_year=min(vehicles[,"year"])
max_year=max(vehicles[,"year"])

table(vehicles$fuelType1)

#按条件筛选某列并将汽传动类型的空值赋值为NA
vehicles$trany[vehicles$trany==""]<-NA  

length(vehicles$trany[vehicles$trany==""]<-NA)
vehicles$trany2<-ifelse(substr(vehicles$trany,1,4)=="Auto","Auto","Manual")

vehicles$trany2<-as.factor(vehicles$trany2) #设置为新变量为因子类型
table(vehicles$trany2)

with(vehicles,table(sCharger,year)) 


#-----------画图描述相关业务

#一、查看近几年来所有汽车每加仑汽油能行驶的公里数  趋势 

#ddply可以将数据集按照制定函数进行计算并且赋给新数据框
#参数1  数据集，2 分类变量 
mpgByYr<-ddply(vehicles,~year,summarise,avgMPG=mean(comb08),avgHghy=mean(highway08),avgCity=mean(city08))
#画图发现现在汽车每加仑汽油行驶的燃油数越来越多
ggplot(mpgByYr,aes(year,avgMPG))+geom_point()+geom_smooth()+xlab("Year")+ylab("Average MPG")+ggtitle("All cars")

table(vehicles$fuelType1) #查看之后发现有很多非汽油动力在里边，数据有误







