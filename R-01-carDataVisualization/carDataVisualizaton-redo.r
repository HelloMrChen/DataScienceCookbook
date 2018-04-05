library(ggplot2)
library(plyr)

setwd("/Users/gavinchen/我的文档/MBA养成记/2-自我提升/2-数据分析/程序练习/数据科学实战手册/R-01-carDataVisualization")

#读取数据文件
vehicle=read.csv("Data/vehicles.csv")
#将变量解释拆分并读进文件
headName<-do.call(rbind,strsplit(readLines("Data/varlabels.txt")," - "))

#查看变量概况
summary(vehicle)
ncol(vehicle)
nrow(vehicle)
names(vehicle)
table(vehicle$fuelType)
table(vehicle$trany) #发现传动类型有11个为“”，需要处理为NA

#数据处理
vehicle$trany[vehicle$trany==""]<-NA
table(vehicle$trany)

with(vehicle,table(year,trany))#在某个数据集下查看year以及trany的列联表

#一、查看近几年每加仑汽油行驶公里数趋势
mpgByYr<-ddply(vehicle,~year,summarise,avgMPG=mean(comb08))
ggplot(mpgByYr,aes(year,avgMPG))+geom_point()+geom_smooth()+xlab("Year")+ylab("Average MPG")+ggtitle("All cars")

#二、筛选出燃油车然后查看每加仑汽油行驶公里数的趋势
gasCar<-subset(vehicle,vehicle$fuelType1 %in% c("Regular Gasoline","Premium Gasoline","midgrade Gasoline")&fuelType2==""&atvType!="Hybrid")
gasCarmpgByYr<-ddply(gasCar,~year,summarise,avgMPG=mean(comb08))
ggplot(gasCarmpgByYr,aes(year,avgMPG))+geom_point()+geom_smooth()+xlab("Year")+ylab("Average MPG")+ggtitle("gasCar MPG")

#三、查看汽车排量和燃油效率的趋势
ggplot(gasCar,aes(displ,comb08))+geom_point()+geom_smooth()
byYear<-ddply(gasCars,~year,summarise,avgMPG=mean(comb08),avgDispl<-mean(displ))
byYear
byyear2=melt(byYear,id="year") #melt 函数将两个列名转化到了数据框中，作为variable，而之前的值作为value
levels(byyear2$variable)<-c("Average MPG","Avg engine displacement")
byyear2

ggplot(byyear2,aes(year,value))+geom_point()+geom_smooth()+facet_wrap(~variable,ncol=1,scales = "free_y")+labs(x="Year",y="")
#这里的facet_wrap 函数variable代表分类依据，ncol代表能分为几列，这样保证了在一个上下图里

