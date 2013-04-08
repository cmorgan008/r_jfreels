vami<-function (ror) { cumprod(na.omit(ror) + 1) }
aror<-function (ror) { (1 + cror(ror))^(12/length(ror)) - 1 }
cror<-function (ror) { tail(vami(ror), 1) - 1 }
asd<-function (ror) { sd(ror) * sqrt(12) }
sharpe<-function (ror) { aror(ror)/asd(ror) }
maxdd<-function (ror) { min(dd(ror)) }
dd<-function (ror) { -(1 - vami(ror)/cummax(c(1, cummax(vami(ror))))[-1]) }
omega<-function (ror) { sum(ror[ror>0])/sum(abs(ror[ror<0])) }

drought<-function (ror) {
  dat<-data.frame(ror=ror,cror=cumprod(ror+1)-1)
  dat2<-transform(dat,index=ldply(apply(dat[,2,drop=FALSE],1,function (y) { which(y<dat[,2,drop=FALSE])}),function (x) { x[1] }))
  names(dat2)<-c("ror","cror","index")
  dat3<-transform(dat2,drought=as.integer(row.names(dat2))-index)
  dat3$drought[dat3$drought<0]<-NA
  dat3$index[is.na(dat3$drought)]<-NA
  dat3
}

droughtMax<-function (ror) { as.integer(max(drought(ror)$drought,na.rm=TRUE)) }
droughtMaxPct<-function (ror) { droughtMax(ror)/length(ror) }

longToXts<-function (longDataFrame) { xts(longDataFrame[,-1],longDataFrame[,1]) }
xtsToLong<-function (Xts) { 
  df<-data.frame(date=index(Xts),coredata(Xts)) 
  names(df)<-c("date",names(Xts))
  df<-melt(df,id.vars="date")
  names(df)<-c("date","fund","return")
  df
}

stats<-function (longDataFrame) {
  ddply(longDataFrame,.(fund),summarise,
        cROR=cror(return)*100,
        aror=aror(return)*100,
        asd=asd(return)*100,
        sharpe=sharpe(return),
        maxdd=maxdd(return)*100,
        maxDroughtPct=droughtMaxPct(return),
        omega=omega(return),
        start=as.character(min(date)),
        end=as.character(max(date)))
}

calendarTable<-function (oneFundLongDataFrame) {
  calendarTable<-dcast(oneFundLongDataFrame,year(date)~month(date),value.var="return")
  names(calendarTable)<-c("Year",month.abb)
  calendarTable<-arrange(calendarTable,-Year)
  row.names(calendarTable)<-calendarTable[,1]
  calendarTable<-calendarTable[,-1]
  calendarTable$Year<-apply(calendarTable,1,aror)
  calendarTable<-round(calendarTable*100,2)
  calendarTable
}