//restApi docs https://www.binance.com/restapipub.html
//Functions:
//(?;`samy;();0b;(enlist `x)!enlist ($;"p";(+;1970.01.01D00:00:00.000000000;(*;`openTime;1000000j)))) //epoch converter
// nouveau si problem de certificats...
//--cacert C:\Users\samse\Downloads\curl\cacert.pem
//create functions and parameters to parse in the query - on my laptop, i need to add cacert.pem otherwise it doesn't work...



//ONEOFFSCRIPT loaderorders.js
order:flip `symbol`orderId`clientOrderId`price`origQty`executedQty`status`timeInForce`type`side`stopPrice`icebergQty`time`isWorking!();
transform4:{x[`symbol`status`timeInForce`type`side]:`$x[`symbol`status`timeInForce`type`side];x[`orderId]:"j"$x[`orderId];x[`price`origQty`executedQty`stopPrice`icebergQty]:"F"$x[`price`origQty`executedQty`stopPrice`icebergQty];x[`time]:timestamptoDT x[`time];x};
upd4:{[x] table:order;order::table  upsert transform4 x};
//get historical trades (same loader:
order2:flip `id`orderId`price`qty`commission`commissionAsset`time`isBuyer`isMaker`isBestMatch!();
transform5:{x[`orderId]:"j"$x[`orderId];x[`commissionAsset]:`$x[`commissionAsset];x[`price`qty`commission]:"F"$x[`price`qty`commission];x[`time]:timestamptoDT x[`time];x};
upd5:{[x] table:order2;order2::table  upsert transform5 x};
DTtoTimestamp:{("f"$("p"$x )- 1970.01.01D00:00:00.000000000)%1000000j };
timestamptoDT:{"p"$1970.01.01D00:00:00.000000000+x*1000000j};
transform:{x[`t`T]:timestamptoDT x[`t`T];x[`s]:`$x[`s];x[`o`c`h`l`v`q`V`Q]:"F"$x[`o`c`h`l`v`q`V`Q];x[`t`T`s`i`f`L`o`c`h`l`v`n`x`q`V`Q]};
Kline:flip `startTime`closeTime`sym`interval`firstTradeID`lastTradeID`open`close`high`low`baseAssetVolume`tradeNumber`isFalse`quoteAssetVolume`takerBuyBaseAssetVolume`takerBuyQuoteeAssetVolume!();
upd:{[x] if[x[`x];table:Kline;Kline::table upsert transform x]};







// need to change few things 
// node C:\Users\Public\temp\loadorders2.js

order:`symbol`orderId`clientOrderId`price`origQty`executedQty`status`timeInForce`Type`side`stopPrice`icebergQty`time`isWorking xcol order;
//update price for order that have been at marketprice
//order:order lj 2!(select from order where Type = `MARKET) lj 1!select orderId, price from order2;
neworder:(select from order where status<>`CANCELED) lj 1!select orderId, price,commission,commissionAsset from order2;





api:"https://api.binance.com";
endPoint:"/api/v1/";
endPointOrder:"/api/v3/";
httpGet:{[api;endPoint;query] system "curl -X GET ",api,endPoint,query," --cacert C:\\Users\\samse\\Downloads\\curl\\cacert.pem"};
postProcess:{.j.k raze x}; // parsing JSON to kdb;
getHisto:{[query] system "curl -X GET ",query};

//curl method, you can show the query and then try directly in browser to see whether the query works or not..
httpGet:{[api;endPoint;query] system "curl -X GET ",api,endPoint,query};

httpGet:{[api;endPoint;query] system "curl -X GET ",api,endPoint,query," --cacert C:\\Users\\samse\\Downloads\\curl\\cacert.pem"};
postProcess:{.j.k raze x}; // parsing JSON to kdb;
/getTime:(postProcess httpGet[api;endPoint;"time"]); //testing with the gettime function
ENUM:`Symbol_type`Order_status`Order_types`Order_side`Time`Kline_intervals!(`SPOT;`NEW`PARTIALLY_FILLED`FILLED`CANCELED`PENDING_CANCEL`REJECTED`EXPIRED;`LIMIT`MARKET;`BUY`SELL;`GTC`IOC;("1m";"3m";"5m";"15m";"30m";"1h";"2h";"4h";"6h";"8h";"12h";"1d";"3d";"1w";"1M"));

//functions:

btcbalance:{
res:aj[`sym;(`sym xcols 0!update sym:`BTCUSDT from (update sym:(`$(string symbol),\:"BTC") from balance) where sym=`BTCBTC);`sym xcol quote];
res:select symbol,available,locked,lastupdate,mid: (bid+ask)%2 from res;
res:update midbtc: res[`mid] 0,btc:sum res[`available`locked][;0] from res;
res:update btc:mid*(available+locked) from res where symbol<> `BTC;
:res}
;
btctotal:{
res:raze value raze select sum btc from btcbalance`;
:res};
usdbalance:{
res:btcbalance`;
res:update USD:btc*res[`midbtc] 0 from res;
:res};
usdtotal:{
res:raze value raze select sum USD from usdbalance`;
:res};

//either this one or the one below***********************************************
//Getting the candlesticks with only retieving the candlesticks (if you subscribe to candlesticks == close = last price
//deviationtable:0!select time:.z.t,first open,first close,first high,first low, first tradeNumber, std1min:dev (first open;first close;first high;first low),std:(dev 10#close),percentchange:((first high)-first low)%first close  by sym from reverse Kline;

//.z.ts:{deviationtable,:0!select time:.z.t,first open,first close,first high,first low, first tradeNumber, std1min:dev (first open;first close;first high;first low),std:(dev 10#close),percentchange:((first high)-first low)%first close  by sym from reverse Kline};
 //\t 60000
//either this one or the one below***********************************************



//Getting the candlesticks 
timestamptoDT:{"p"$1970.01.01D00:00:00.000000000+x*1000000j};
transform:{x[`t`T]:timestamptoDT x[`t`T];x[`s]:`$x[`s];x[`o`c`h`l`v`q`V`Q]:"F"$x[`o`c`h`l`v`q`V`Q];x[`t`T`s`i`f`L`o`c`h`l`v`n`x`q`V`Q]};
Kline:flip `startTime`closeTime`sym`interval`firstTradeID`lastTradeID`open`close`high`low`baseAssetVolume`tradeNumber`isFalse`quoteAssetVolume`takerBuyBaseAssetVolume`takerBuyQuoteeAssetVolume!();
upd:{[x] ;table:Kline;Kline::table upsert transform x};

//get the balance 
balance:1!flip `symbol`available`locked`lastupdate!();
transform2:{x[`symbol]:`$x[`symbol];x[`available`locked]:"F"$x[`available`locked];x[`lastupdate]:.z.p;x};
upd2:{[x] table:balance;balance::table  upsert transform2[(`symbol`available`locked!x)]};
//get the depth
depth:flip `date`time`symbol`bid`bid_size`ask`ask_size!();
transform3:{x[`symbol]:`$x[`symbol];x[`bid] :"F"$string key x`bids; x[`bid_size] :value x`bids;   x[`ask] :"F"$string key x`asks; x[`ask_size] :value x`asks;x[`date]:"d"$.z.p;x[`time]:"n"$.z.p;x[`date`time`symbol`bid`bid_size`ask`ask_size]};
upd3:{[x] table:depth;depth::table  upsert transform3(`symbol`bids`asks!x)};

//daily change and max percentage change
DailyChange:(postProcess httpGet[api;"/api/v1/ticker/";"24hr"]);
![`DailyChange;();0b;(`symbol`priceChange`priceChangePercent`weightedAvgPrice`prevClosePrice`lastPrice`lastQty`bidPrice`bidQty`askPrice`askQty`openPrice`highPrice`lowPrice`volume`quoteVolume`openTime`closeTime)!(($;enlist `;`symbol);($;"F";`priceChange);($;"F";`priceChangePercent);($;"F";`weightedAvgPrice);($;"F";`prevClosePrice);($;"F";`lastPrice);($;"F";`lastQty);($;"F";`bidPrice);($;"F";`bidQty);($;"F";`askPrice);($;"F";`askQty);($;"F";`openPrice);($;"F";`highPrice);($;"F";`lowPrice);($;"F";`volume);($;"F";`quoteVolume);($;"p";(+;1970.01.01D00:00:00.000000000;(*;`openTime;1000000j)));($;"p";(+;1970.01.01D00:00:00.000000000;(*;`closeTime;1000000j))))];
//best btc to trade IE worst performer, check the graph and see if there is an opportunity



//refData
refData:(postProcess httpGet[api;endPoint;"exchangeInfo"])`symbols;

//system"curl -X GET https://api.binance.com/",,"api/v1/","exchangeInfo"}

definition:([] queryDescription:();endPoint:();query:();parameters:();Type:();Mandatory:();Description:());
definition,:`queryDescription`endPoint`query`parameters`Type`Mandatory`Description!("Test connectivity to the Rest API";"/api/v1/";"ping";`;`;`;"");
definition,:`queryDescription`endPoint`query`parameters`Type`Mandatory`Description!("Order book";"/api/v1/";"depth";`symbol;`STRING;`Y;"");
definition,:`queryDescription`endPoint`query`parameters`Type`Mandatory`Description!("Order book";"/api/v1/";"depth";`limit;`INT;`N;"Default 100; max 100");

definition,:`queryDescription`endPoint`query`parameters`Type`Mandatory`Description!("Compressed/Aggregate trades list";"/api/v1/";"aggTrades";`symbol;`STRING;`Y;"");
definition,:`queryDescription`endPoint`query`parameters`Type`Mandatory`Description!("Compressed/Aggregate trades list";"/api/v1/";"aggTrades";`fromId;`LONG;`N;"ID to get aggregate trades from INCLUSIVE");
definition,:`queryDescription`endPoint`query`parameters`Type`Mandatory`Description!("Compressed/Aggregate trades list";"/api/v1/";"aggTrades";`startTime;`LONG;`N;"Timestamp in ms to get aggregate trades from INCLUSIVE");
definition,:`queryDescription`endPoint`query`parameters`Type`Mandatory`Description!("Compressed/Aggregate trades list";"/api/v1/";"aggTrades";`endTime;`LONG;`N;"Timestamp in ms to get aggregate trades until INCLUSIVE");
definition,:`queryDescription`endPoint`query`parameters`Type`Mandatory`Description!("Compressed/Aggregate trades list";"/api/v1/";"aggTrades";`limit;`LONG;`N;"Default 500; max 500");

definition,:`queryDescription`endPoint`query`parameters`Type`Mandatory`Description!("Kline/candlesticks";"/api/v1/";"klines";`symbol;`STRING;`Y;"");
definition,:`queryDescription`endPoint`query`parameters`Type`Mandatory`Description!("Kline/candlesticks";"/api/v1/";"klines";`interval;`ENUM;`Y;"");
definition,:`queryDescription`endPoint`query`parameters`Type`Mandatory`Description!("Kline/candlesticks";"/api/v1/";"klines";`limit;`INT;`N;"Default 500; max 500");
definition,:`queryDescription`endPoint`query`parameters`Type`Mandatory`Description!("Kline/candlesticks";"/api/v1/";"klines";`startTime;`LONG;`N;"");
definition,:`queryDescription`endPoint`query`parameters`Type`Mandatory`Description!("Kline/candlesticks";"/api/v1/";"klines";`endTime;`LONG;`N;"");

definition,:`queryDescription`endPoint`query`parameters`Type`Mandatory`Description!("24hr ticker price change statistics";"/api/v1/ticker/";"24hr";`symbol;`STRING;`N;"");

definition,:`queryDescription`endPoint`query`parameters`Type`Mandatory`Description!("Symbol price ticker";"/api/v3/ticker/";"price";`symbol;`STRING;`N;"");

definition,:`queryDescription`endPoint`query`parameters`Type`Mandatory`Description!("Symbol order book ticker";"/api/v3/ticker/";"bookTicker";`symbol;`STRING;`N;"");

definition,:`queryDescription`endPoint`query`parameters`Type`Mandatory`Description!("Symbol order book ticker";"/api/v3/ticker/";"bookTicker";`symbol;`STRING;`N;"");

definition,:`queryDescription`endPoint`query`parameters`Type`Mandatory`Description!("Account information";"/api/v3/";"account";`recvWindow;`LONG;`N;"");
definition,:`queryDescription`endPoint`query`parameters`Type`Mandatory`Description!("Account information";"/api/v3/";"account";`timestamp;`LONG;`Y;""); // you can get the timestamp by using "raze getTime"

definition,:`queryDescription`endPoint`query`parameters`Type`Mandatory`Description!("Get trades for a specific account";"/api/v3/";"myTrades";`symbol;`STRING;`Y;"");
definition,:`queryDescription`endPoint`query`parameters`Type`Mandatory`Description!("Get trades for a specific account";"/api/v3/";"myTrades";`limit;`INT;`N;"Default 500; max 500"); 
definition,:`queryDescription`endPoint`query`parameters`Type`Mandatory`Description!("Get trades for a specific account";"/api/v3/";"myTrades";`fromId;`LONG;`N;"TradeId to fetch from. Default gets most recent trades");
definition,:`queryDescription`endPoint`query`parameters`Type`Mandatory`Description!("Get trades for a specific account";"/api/v3/";"myTrades";`recvWindow;`LONG;`N;"");
definition,:`queryDescription`endPoint`query`parameters`Type`Mandatory`Description!("Get trades for a specific account";"/api/v3/";"myTrades";`timestamp;`LONG;`Y;""); // you can get the timestamp by using "raze getTime"


//.z.ts:{quote::0!select bid:last bid[;0],bid_size:last bid_size[;0],ask:last ask[;0],ask_size:last ask_size[;0],lastupdate:.z.p by symbol from depth;show "quote updated at time ",string .z.p;if[(.z.t-(last depth)`time) >00:05;show "depth not ticking"]};


//select from `priceChangePercent xasc DailyChange where symbol like "*BTC*"


//open loadorder.js and test.js first as quote needs depth to calculate

 // \t 300000



//https://www.babypips.com/learn/forex/japanese-candlesticks-cheat-sheet
//sym:("AMB";"BNT";"CDT";"DGD";"ENG";"EOS";"ETH";"EVX";"GAS";"ICX";"IOTA";"KMD";"LEND";"LUN";"MOD";"NAV";"NEBL";"NEO";"NULS";"OMG";"PPT";"RDN";"REQ";"RLC";"SALT";"SNGLS";"SNM";"SNT";"STRAT";"SUB";"TNT";"VEN";"VIB";"WABI";"WINGS";"WTC";"XLM";"ZEC";"ZRX");
sym:("TRX";"LEND";"LINK";"NULS";"MOD";"BNB";"NEO";"ETH";"KNC";"ENG";"BNT";"ADA";"VIB";"WTC";"VEN";"ICX";"LSK";"WABI");
sym:("NEO";"ETH";"BNT";"KNC";"TRX";"ADA";"ENG";"VEN";"WABI");

//sym:("MOD";"RLC";"NULS";"OMG";"AION";"IOTA";"LINK";"LEND";"TRX");
// If i want to subscribe to all tickers from DailyChange table - you might have symbols where there is no data, thus there is an error hanmdler within the function and also before calculating the correlation by deleting rows with 0
//sym:{ssr[x;"BTC";""]} each string raze flip select symbol from DailyChange where symbol like "*BTC", not symbol like "IOSTBTC";

populateHisto:{[ccy1] ccy2:"BTC";
                    days:string 365;
                    query:"\"https://min-api.cryptocompare.com/data/histoday?fsym=",ccy1,"&tsym=",ccy2,"&limit=",days,"&aggregate=1&e=Binance\"";
//                    query:"\"https://min-api.cryptocompare.com/data/histoday?fsym=",ccy1,"&tsym=",ccy2,"&limit=",days,"&aggregate=1&e=Binance\"";
                     if[0<>count prices:(postProcess getHisto query)`Data;
                            histo,:`time`sym xcols update sym:`$(ccy1,ccy2), time:"d"$timestamptoDT time*1000,average:sum (1 2 2 1) * (low;close;open;high) %6 from prices]
                };




//TESTBTCUSD

//hourly table
rsitable
//daily table
histo 

res:select time,sym,close from histo where sym = `NEOBTC

`res 0: csv 0: `$":C:\\temp\\kdb\\res.csv"

(`$":C:\\temp\\kdb\\res.csv") 0: csv 0: res


//sym:{ssr[x;"BTC";""]} each string raze flip select symbol from DailyChange where symbol like "*BTC", not symbol like "IOSTBTC";

populateHisto2:{[ccy1] ccy2:"BTC";
                    days:string 365;
                    query:"\"https://min-api.cryptocompare.com/data/histoday?fsym=",ccy1,"&tsym=",ccy2,"&limit=",days,"&aggregate=1&e=Binance\"";
//                    query:"\"https://min-api.cryptocompare.com/data/histoday?fsym=",ccy1,"&tsym=",ccy2,"&limit=",days,"&aggregate=1&e=Binance\"";
                     if[0<>count prices:(postProcess getHisto query)`Data;
                            histo,:`time`sym xcols update sym:`$(ccy1,ccy2), time:"d"$timestamptoDT time*1000,average:sum (1 2 2 1) * (low;close;open;high) %6 from prices]
                };

//neo
query:"\"https://min-api.cryptocompare.com/data/histoday?fsym=NEO&tsym=USD&limit=2000&aggregate=1\""
//btc
query:"\"https://min-api.cryptocompare.com/data/histoday?fsym=BTC&tsym=USD&limit=2000&aggregate=1\""

prices:(postProcess getHisto query)`Data;
prices:`time`sym xcols update sym:`$("BTC","USD"), time:"d"$timestamptoDT time*1000,average:sum (1 2 2 1) * (low;close;open;high) %6 from prices;
res:select time,sym,close from prices

(`$":C:\\temp\\kdb\\btcusd.csv") 0: csv 0: res
//TESTBTCUSD


query:"\"https://min-api.cryptocompare.com/data/histoday?fsym=BTC&tsym=USD&limit=30&aggregate=1\"";
//getting usd price - not mandatory + i am only using it when backtesting with 1000 dollars and not 1btc (absolute growth...)
btcusd:flip(`time`sym`close`high`low`open`volumefrom`volumeto`average)!(`date$();`symbol$();`float$();`float$();`float$();`float$();`float$();`float$();`float$());
btcusd:`time`sym xcols update sym:`BTCUSD, time:"d"$timestamptoDT time*1000,average:sum (1 2 2 1) * (low;close;open;high) %6 from ((postProcess getHisto query)`Data);

//=>we can take matrix of correlation
histo:flip(`time`sym`close`high`low`open`volumefrom`volumeto`average)!(`date$();`symbol$();`float$();`float$();`float$();`float$();`float$();`float$();`float$());

populateHisto each sym;


//histo:`time xasc histo;
//knowing the % in btc for 1000$:
//btcusd price on the day (i.e.
//1btc = $14398.7
//$1000 = 1000/14398.7
//btc = 1000%14398.7
//btcval:1000%14398.7;

//backtesting

//here you can specify your parameters within your PF and then calculate the daily growth by sym

//pf:([] sym:`$sym,\:"BTC";prop:0.05270468 0.02004536 0.01043974 0.01907354 0.019446 0.003967 0.01653179);
pf:([] sym:`$sym,\:"BTC";prop:25 10 10 10 10 5 10 5 5);

pf:([] sym:`$sym,\:"BTC";prop:1);

histotmp:histo;
//to delete histo than are nuls

delete from `histotmp where sym in (exec distinct sym from histotmp where average=0);
ini:select sym,uopen:open from histotmp where time= exec first time from histotmp;
histotmp:histotmp lj 1!ini;
histotmp:histotmp lj 1!pf;
update growth:(close-uopen)%uopen from `histotmp;
update position:prop*1+growth,pnl:growth*prop from `histotmp;
growth:select daily:sum position by time from histotmp;
select daily:sum position,worst:min pnl,best:max pnl by time from histotmp;


DailyChange:(postProcess httpGet[api;"/api/v1/ticker/";"24hr"]);
![`DailyChange;();0b;(`symbol`priceChange`priceChangePercent`weightedAvgPrice`prevClosePrice`lastPrice`lastQty`bidPrice`bidQty`askPrice`askQty`openPrice`highPrice`lowPrice`volume`quoteVolume`openTime`closeTime)!(($;enlist `;`symbol);($;"F";`priceChange);($;"F";`priceChangePercent);($;"F";`weightedAvgPrice);($;"F";`prevClosePrice);($;"F";`lastPrice);($;"F";`lastQty);($;"F";`bidPrice);($;"F";`bidQty);($;"F";`askPrice);($;"F";`askQty);($;"F";`openPrice);($;"F";`highPrice);($;"F";`lowPrice);($;"F";`volume);($;"F";`quoteVolume);($;"p";(+;1970.01.01D00:00:00.000000000;(*;`openTime;1000000j)));($;"p";(+;1970.01.01D00:00:00.000000000;(*;`closeTime;1000000j))))];
//best btc to trade IE worst performer, check the graph and see if there is an opportunity


// this code is here to be able to download the latest price vs btc
//command to be run to get data for my spreadsheet

select x from (`x xcols `symbol xasc select symbol, 100000000*lastPrice from DailyChange where symbol like "*BTC", not symbol like "IOSTBTC",not symbol like "CHATBTC");


//correlation:

computeCorrelation:{[x]
        
        cc1:first string x;
        cc2:last string x;
   //     $[(reverse x)in memory; [show cc1,cc2,"already in memmory"; :0b]; memory,:enlist x];
        l1:(histo @where histo[`sym]=`$cc1,"BTC")`average;
        l2:(histo @where histo[`sym]=`$cc2,"BTC")`average;
        `corr upsert enlist `sym`corr!(`$cc1,cc2;l1 cor l2);
    };

//generate correlation for ALL ccys: ****************************************
// you can generate correlation just for the sym you want, you just need to parse the sym like sym2:("ETC";"LRC";"OMG); 

//deleting the syms that have 0 average in any condition as we won't have the same number of occurence to do the correlation - 
sym2:{ssr[x;"BTC";""]} each string exec distinct sym from histo where average<>0;
//correlation computation:
corr:flip(`sym`corr)!(`symbol$();`float$());

sym2:`$sym2;
//computeCorrelation each distinct asc each sym2 cross sym2;
computeCorrelation each sym2 cross sym2 ;



corr2:corr @ where corr[`sym] in `$raze each string (sym2 cross sym2);
//lala:{((flip corr2@ where corr2[`sym] like (string x),"*")`sym)} each sym3
//sym3!(((flip corr2@ where corr2[`sym] like "LRC*")`corr);((flip corr2@ where corr2[`sym] like "MOD*")`corr);((flip corr2@ where corr2[`sym] like "NEO*")`corr))
mycorr:`id xkey update id:sym2 from flip sym2!{((flip corr2@ where corr2[`sym] in `$(string x),/:string sym2)`corr)} each sym2;

//*******************************************************************************************************
//25% NEO, 
//10% ETH
//15% VEN
//10% GXS
//10% trx (risk)
//20% risky capital (less than 3-day trading with 5-10% returns max) 
//10% btc buffer whenever i see oportunities

//not sure about GXS trx, i am more thinking about LUN n ICX 

httpGet:{[api;endPoint;query] system "curl -X GET ",api,endPoint,query," --cacert C:\\Users\\samse\\Downloads\\curl\\cacert.pem"};
postProcess:{.j.k raze x}; // parsing JSON to kdb;
getHisto:{[query] system "curl -X GET ",query," --cacert C:\\Users\\samse\\Downloads\\curl\\cacert.pem"};

sym:{ssr[x;"BTC";""]} each string exec symbol from DailyChange where symbol like "*BTC";

rsitable:flip(`time`sym`close`high`low`open`volumefrom`volumeto`change`gain`loss`avgGain`avgLoss`rs`rsi)!(`timestamp$();`symbol$();`float$();`float$();`float$();`float$();`float$();`float$();`float$();`float$();`float$();`float$();`float$();`float$();`float$());
//         rsitable:flip(`time`sym`close`high`low`open`volumefrom`volumeto`change`gain`loss`avgGain`avgLoss`rs`rsi`EMA12`EMA26`macd)!(`timestamp$();`symbol$();`float$();`float$();`float$();`float$();`float$();`float$();`float$();`float$();`float$();`float$();`float$();`float$();`float$();`float$();`float$();`float$());
ccy1:first sym
populateRSIalerts:{[ccy1] 
                
                ccy2:"BTC";
                 days:string 320;
                    f:{(14#0Nf),(avg 14#x),{(y+x*13)%14}\[(sum 14#x)%14;15_x]};

                    //query:"\"https://min-api.cryptocompare.com/data/histoday?fsym=",ccy1,"&tsym=",ccy2,"&limit=",days,"&aggregate=1&e=Binance\"";
                     query: "\"https://min-api.cryptocompare.com/data/histohour?fsym=",ccy1,"&tsym=",ccy2,"&limit=",days,"&aggregate=1\""  ;                
//                    query:"\"https://min-api.cryptocompare.com/data/histoday?fsym=",ccy1,"&tsym=",ccy2,"&limit=",days,"&aggregate=1&e=Binance\"";
                     if[0<>count prices:(postProcess getHisto query)`Data;
                  //RSI part
                        prices:update change:close -open from prices;
                        prices:update gain:abs change*change>0, loss:abs change*change<0 from prices;
                        prices:update avgGain:f gain,avgLoss:f loss from prices;
                        prices:update rs:avgGain%avgLoss from prices;
                        prices:update rsi:?[avgLoss=0;100;100*rs%(1+rs)] from prices;
                 //if ema:
//         rsitable:flip(`time`sym`close`high`low`open`volumefrom`volumeto`change`gain`loss`avgGain`avgLoss`rs`rsi`EMA12`EMA26`macd)!(`timestamp$();`symbol$();`float$();`float$();`float$();`float$();`float$();`float$();`float$();`float$();`float$();`float$();`float$();`float$();`float$();`float$();`float$();`float$());
                //ema part
//                        start:12;
//                        alpha:(2%(start+1));

//                        ema12:(functEMA3) scan raze (enlist(avg (start)#prices`close;prices[start][`close]);value each 1_select i,close from (start)_prices);
//                        prices:update EMA12:((start#0nf),ema12[;0]) from prices;
                        
//                        start:26;
//                        alpha:(2%(start+1));
                        
//                        ema26:(functEMA3) scan raze (enlist(avg (start)#prices`close;prices[start][`close]);value each 1_select i,close from (start)_prices);
//                        prices:update EMA26:((start#0nf),ema26[;0]) from prices;

//                        prices:update macd:EMA26-EMA12 from prices;
               
                        //publishing rsitable
                         rsitable,:`time`sym xcols update sym:`$(ccy1,ccy2), time:timestamptoDT time*1000 from prices;
                        ];
                  
                };

        populateRSIalerts each sym;
        select count i by sym from rsitable;
        lastUpdate:select last sym,last close,last high,last low, last open,last volumeto,last change,last rsi by sym from rsitable;

.z.ts:{
    show .tmp.lastTime:.z.t;

        rsitable::flip(`time`sym`close`high`low`open`volumefrom`volumeto`change`gain`loss`avgGain`avgLoss`rs`rsi`EMA12`EMA26`macd)!(`timestamp$();`symbol$();`float$();`float$();`float$();`float$();`float$();`float$();`float$();`float$();`float$();`float$();`float$();`float$();`float$();`float$();`float$();`float$());
        populateRSIalerts each sym;
        lastUpdate:select last sym,last close,last high,last low, last open,last volumeto,last change,last rsi by sym from rsitable;
            if[0<>count rsialert:select from rsitable where sym in exec sym from lastUpdate where volumeto<>0,rsi<25;
                `rsialert.csv 0: .h.tx[`csv;0!rsialert];`lastUpdate.csv 0: .h.tx[`csv;`time xdesc 0!lastUpdate]; //save files
                system "mailsend1.19.exe -t smurfhots415@gmail.com -f smurfhots415@gmail.com -ssl -port 465 -auth -smtp smtp.gmail.com -sub subject -M message -user smurfhots415@gmail.com -pass Supersam415. -attach rsialert.csv -attach lastUpdate.csv";
              ];
};
//.tmp.lastTime
\t 3600000



samy2:select bid_size from samy
(update change:(0nj,1_deltas bid_size) from `samy2)
samy2:update avgGain:((14#0nf),14_mavg[14;advag]),avgLoss:abs ((14#0nf),14_mavg[14;decl]) from (update advag:{$[0<x;x;0nj]}each change,decl:abs {$[0>x;x;0nj]}each change from samy2)
samy3:update smoothRS:((0^advag)+13*avgGainPrev)%((0^decl)+13*avgLossPrev) from (update avgGainPrev:avgGain[i-1],avgLossPrev:avgLoss[i-1] from (update RS:avgGain%avgLoss from samy2))
update rsi:((13#0nf),13_(100-100%1+smoothRS)) from samy3

 

 rsitable


t:([] a:til 50;p:5+til 50)

functEMA3:{((alpha*y[1])+x[0]*(1-alpha);y[1])};

//res:(functEMA3) scan raze (enlist 5 5;value each 1_select i,p from t);
start:12;
alpha:(2%(start+1));

ema12:(functEMA3) scan raze (enlist(avg (start)#rsitable`close;rsitable[start][`close]);value each 1_select i,close from (start)_rsitable);
rsitable:update EMA12:((start#0nf),ema12[;0]) from rsitable;

start:26;
alpha:(2%(start+1));

ema26:(functEMA3) scan raze (enlist(avg (start)#rsitable`close;rsitable[start][`close]);value each 1_select i,close from (start)_rsitable);
rsitable:update EMA:((start#0nf),ema26[;0]) from rsitable;

 

 
//

//
////RSI
//populateHistoHours:{[ccy1] ccy2:"BTC";
//                    days:string 24;
//                    //query:"\"https://min-api.cryptocompare.com/data/histoday?fsym=",ccy1,"&tsym=",ccy2,"&limit=",days,"&aggregate=1&e=Binance\"";
//                     query: "\"https://min-api.cryptocompare.com/data/histohour?fsym=",ccy1,"&tsym=",ccy2,"&limit=",days,"&aggregate=1\""  ;                
////                    query:"\"https://min-api.cryptocompare.com/data/histoday?fsym=",ccy1,"&tsym=",ccy2,"&limit=",days,"&aggregate=1&e=Binance\"";
//                     if[0<>count prices:(postProcess getHisto query)`Data;
//                            histohours,:`time`sym xcols update sym:`$(ccy1,ccy2), time:timestamptoDT time*1000,average:sum (1 2 2 1) * (low;close;open;high) %6 from prices]
//                };
//
//histohours:flip(`time`sym`close`high`low`open`volumefrom`volumeto`average)!(`timestamp$();`symbol$();`float$();`float$();`float$();`float$();`float$();`float$();`float$());
////populateHistoHours first sym;
//populateHistoHours each sym;
//
//TechnicalAnalysisTable:update change:close -open from histohours;
//update gain:abs change*change>0, loss:abs change*change<0 from `TechnicalAnalysisTable;
//f:{(14#0Nf),(avg 14#x),{(y+x*13)%14}\[(sum 14#x)%14;15_x]};
//update avgGain:f gain,avgLoss:f loss from `TechnicalAnalysisTable;
//update rs:avgGain%avgLoss from `TechnicalAnalysisTable;
//update rsi:?[avgLoss=0;100;100*rs%(1+rs)] from `TechnicalAnalysisTable;
//
//
//lastUpdate:select last sym,last close,last high,last low, last open,last volumeto,last average,last change,last avgGain,last avgLoss,last rsi by sym from TechnicalAnalysisTable;
//
//    if[0<>count rsialert:select from lastUpdate where (rsi<20 or rsi>80) ;
//        `rsialert.csv 0: .h.tx[`csv;0!rsialert];
//        system "mailsend1.19.exe -t smurfhots415@gmail.com -f smurfhots415@gmail.com -ssl -port 465 -auth -smtp smtp.gmail.com -sub subject -M message -user smurfhots415@gmail.com -pass Supersam415. -attach rsialert.csv";
//      ]
////mailsend in C:\temp
////in .z.ts to create an alert system 
//
//        histohours:flip(`time`sym`close`high`low`open`volumefrom`volumeto`average)!(`timestamp$();`symbol$();`float$();`float$();`float$();`float$();`float$();`float$();`float$());
//populateHistoHours each ("LINK";"NEO")
//.z.ts:{
//        histohours:flip(`time`sym`close`high`low`open`volumefrom`volumeto`average)!(`timestamp$();`symbol$();`float$();`float$();`float$();`float$();`float$();`float$();`float$());
//        //populateHistoHours first sym;
//        populateHistoHours each sym;
//        
//        TechnicalAnalysisTable:update change:close -open from histohours;
//        update gain:abs change*change>0, loss:abs change*change<0 from `TechnicalAnalysisTable;
//        f:{(14#0Nf),(avg 14#x),{(y+x*13)%14}\[(sum 14#x)%14;15_x]};
//        update avgGain:f gain,avgLoss:f loss from `TechnicalAnalysisTable;
//        update rs:avgGain%avgLoss from `TechnicalAnalysisTable;
//        update rsi:?[avgLoss=0;100;100*rs%(1+rs)] from `TechnicalAnalysisTable;
//        
//        lastUpdate:select last sym,last close,last high,last low, last open,last volumeto,last change,last rsi by sym from TechnicalAnalysisTable;
//        rsitable:select from TechnicalAnalysisTable where sym in exec from lastUpdate where volumeto<>0,(rsi<20 )or rsi>80
//
//
//            if[0<>count rsialert:select sym from lastUpdate where (rsi<20 )or rsi>80;
//                `rsialert.csv 0: .h.tx[`csv;0!rsialert];
//                system "mailsend1.19.exe -t smurfhots415@gmail.com -f smurfhots415@gmail.com -ssl -port 465 -auth -smtp smtp.gmail.com -sub subject -M message -user smurfhots415@gmail.com -pass Supersam415. -attach rsialert.csv";
//              ]
//}






// Order endpoints not to be done now -- doc : C:\Temp\kdb\binance-official-api-docs-master\rest-api.md

//             https://www.binance.com/api/v1/depth?symbol=BNBBTC&limit=5
//node test.js

//https://www.binance.com/api/v1/depth?symbol=BNBBTC&limit=5

//CALCUL PNL



//mettre en place les algo de bougies japonaises

//PNL STUFF:
//depth:([] date:`date$();time:();sym:`$();bid:();bid_size:();ask:();ask_size:())

//config
//lvl:5;
//sym:("ADABTC";"BNBBTC";"BTGBTC";"CNDBTC";"DGDBTC";"DNTBTC";"EDOBTC";"ETHBTC";"LENDBTC";"NEOBTC";"OMGBTC";"SALTBTC";"STRATBTC";"TRXBTC";"VIBBTC";"WAVESBTC";"XLMBTC";"XRPBTC";"XZCBTC";"ZECBTC");


//depthUpd:{[sym]
//    query:"depth?symbol=",sym;
//    samy:((postProcess httpGet[api;endPoint;query])`bids`asks);
//    lo:`bid`bid_size`ask`ask_size!("F"$(samy[0;til lvl;0];samy[0;til lvl;1];samy[1;til lvl;0];samy[1;til lvl;1]));
//    lo:(`date`time`sym,key lo)!((.z.d;.z.t;`$sym),value lo);
//    `depth upsert lo} 

//.z.ts:{depthUpd each sym}

//\t 600000

//x:`$"C:\\temp\\trades.csv";
//table:distinct (("TSSFFF*"; enlist ",") 0: x);
//update Fee:"F"$Fee[;til 10],Fee_ccy:`$Fee[;11 12 13] from `table;
//update Price:-1*Price,Total:-1*Total,Filled:-1*Filled from `table where Type=`Buy;
//// NEO ETH ETH/BTC on the 9th: 0.0795
//update Pair:`$"NEO/BTC", price:0.0795*Price,Total:0.0795*Total from `table where Pair=`$"NEO/ETH";
//quid of ETH/BTC?

//la:0!select sum Total, sum Filled by Pair from table ;
//update Pair:`${ssr[x;"/";""]} each string Pair from `la;
//la:update RealisedPnL:Total from la where Filled =0;



//la:0!select sum Total, sum Filled by Pair from table ;
//la:select from la where Filled <>0;
//create a table to join it 
//po:?[(neg count sym)#depth;();0b;`Pair`bid`ask!(`sym;(`bid;::;0j);(`ask;::;0j))];

//pnl:![(update UnrealisedPnL:-1 * bid* Filled + Total from lj[la;1!po] where Filled <>0);();0b;`bid`ask];
//usdt:raze flip select last bid[;0] from depth where sym=`BTCUSDT;
//type usdt

//select pnl:(sum RealisedPnL) +sum UnrealisedPnL from pnl

