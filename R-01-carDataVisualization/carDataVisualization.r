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
ggplot(mpgByYr,aes(year,avgMPG))+geom_point()+geom_smooth()+xlab("Year")+ylab("Average MPG")+ggtitle("All cars")#geom_smooth的使用

table(vehicles$fuelType1) #查看之后发现有很多非汽油动力在里边，数据有误

#二、筛选出燃油车然后查看MPG趋势 

gasCars<-subset(vehicles,fuelType1 %in%c("Regular Gasoline","Premium Gasoline","midgrade Gasoline")&fuelType2==""&atvType!="Hybrid")
nrow(gasCars);nrow(vehicles)
table(gasCars$fuelType1)  #注意table函数应用
GascarmpgByYr<-ddply(gasCars,~year,summarise,avgMPG=mean(comb08),avgHghy=mean(highway08),avgCity=mean(city08))
ggplot(GascarmpgByYr,aes(year,avgMPG))+geom_point()+geom_smooth()+xlab("Year")+ylab("Average MPG")+ggtitle("All cars")

#三、查看汽车排量和燃油效率的趋势
typeof(gasCars$displ)
gasCars$displ<-as.numeric(gasCars$displ)
ggplot(gasCars,aes(displ,comb08))+geom_point()+geom_smooth()

#四、查看近几年生产车型的趋势
avgCarSize<-ddply(gasCars,~year,summarise,avgDispl=mean(displ))
ggplot(avgCarSize,aes(year,avgDispl))+xlab("year")+ylab("avgDispl")+geom_point()+geom_smooth()

#五、查看引擎排量和和MPG之间的关系
byYear<-ddply(gasCars,~year,summarise,avgMPG=mean(comb08),avgDispl<-mean(displ))

byyear2=melt(byYear,id="year") #melt 函数？
levels(byyear2$variable)<-c("Average MPG","Avg engine displacement")
byyear2
nrow(byyear2)

ggplot(byyear2,aes(year,value))+geom_point()+geom_smooth()+facet_wrap(~variable,ncol = 1,scales = "free_y")+xlab("Year")+ylab("")

#六、根据五中排量comb08与MPG在2006年左右的矛盾关系，查看是否自动挡或者手动挡比四缸发动机更加高效
gasCars4<-subset(gasCars,cylinders=="4")

ggplot(gasCars4,aes(factor(year),comb08))+geom_boxplot()+facet_wrap(~trany2,ncol = 1)+theme(axis.title.x = element_text(angle = 45))+labs(x="year",y="MPG")

#七、查看每一年手动挡的车占比情况
ggplot(gasCars4,aes(factor(year),fill=factor(trany2)))+geom_bar(position = "fill")
+labs(x="Year",y="Proportion of cars",fill="Transmission")+theme(axis.text.x = element_text(angle = 45))+geom_hline(yintercept=0.5,lintype=2)
#发现随着随着年份的增多，自动车占比越来越多 

#八、查看汽车生产厂商随年份的变化 
carsMakes<-ddply(gasCars,~year,summarise,numberofMakers=length(unique(make)))
ggplot(carsMakes,aes(year,numberofMakers))+geom_point()+labs(x="Year",y="Number of makers")+ggtitle("Four cylinder Cars")


#九、选出每年制造4缸发动机的厂商，并看这些厂商每年制造的汽车燃油效率如何
uniqueMakes<-dlply(gasCars4,~year,function(x) unique(x$make))
commonMakes<-Reduce(intersect,uniqueMakes)
carsCommonMakes4<-subset(gasCars4,make %in% commonMakes)

#这里按照两个变量进行分组统计，所以分为了
avgMpg_commonMakers<-ddply(carsCommonMakes4,~year+make,summarise,avg_MPG=mean(comb08))
avgMpg_commonMakers
ggplot(avgMpg_commonMakers,aes(year,avg_MPG))+geom_line()+facet_wrap(~make,ncol=3)
#可以看到每个厂商的燃油效率都是提高了的


