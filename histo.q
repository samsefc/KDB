api:"https://api.binance.com";
endPoint:"/api/v1/";
endPointOrder:"/api/v3/";

postProcess:{.j.k raze x}; // parsing JSON to kdb;
curl:{[query] system "curl -X GET ",query};
DTtoTimestamp:{("f"$("p"$x )- 1970.01.01D00:00:00.000000000)%1000000j };
timestamptoDT:{"p"$1970.01.01D00:00:00.000000000+x*1000000j};


//daily change and max percentage change
DailyChange:(postProcess curl[api,"/api/v1/ticker/24hr"]);
![`DailyChange;();0b;(`symbol`priceChange`priceChangePercent`weightedAvgPrice`prevClosePrice`lastPrice`lastQty`bidPrice`bidQty`askPrice`askQty`openPrice`highPrice`lowPrice`volume`quoteVolume`openTime`closeTime)!(($;enlist `;`symbol);($;"F";`priceChange);($;"F";`priceChangePercent);($;"F";`weightedAvgPrice);($;"F";`prevClosePrice);($;"F";`lastPrice);($;"F";`lastQty);($;"F";`bidPrice);($;"F";`bidQty);($;"F";`askPrice);($;"F";`askQty);($;"F";`openPrice);($;"F";`highPrice);($;"F";`lowPrice);($;"F";`volume);($;"F";`quoteVolume);($;"p";(+;1970.01.01D00:00:00.000000000;(*;`openTime;1000000j)));($;"p";(+;1970.01.01D00:00:00.000000000;(*;`closeTime;1000000j))))];
//best btc to trade IE worst performer, check the graph and see if there is an opportunity

//all btc data
symList:(`$-3_/:string exec symbol from DailyChange where symbol like "*BTC"),\:`BTC;
//sample symList
symList:(`TRX`BTC;`LEND`BTC;`LINK`BTC;`NULS`BTC;`MOD`BTC;`BNB`BTC;`NEO`BTC;`ETH`BTC;`KNC`BTC;`ENG`BTC;`BNT`BTC;`ADA`BTC;`VIB`BTC;`WTC`BTC;`VEN`BTC;`ICX`BTC;`LSK`BTC;`WABI`BTC);
params:`ccy`frequency`cfg!(symList;744;`hour); //either hour or day
params:`ccy`frequency`cfg!(symList;365*2;`day);
//params:enlist[`ccy]!enlist[5#symList]; //works
//any (system "curl \"https://min-api.cryptocompare.com/data/histoday?fsym=BCC&tsym=BTC&limit=730&aggregate=1&e=Binance\"") like "*Error*"
queryBuilder:{[params] //query builder 
//cfg can only be day or hour
        cfg:params`cfg;frequency:string params`frequency;ccy:string params`ccy;
            $[`day~params`cfg;
                    query:"\"https://min-api.cryptocompare.com/data/histoday?fsym=",ccy[0],"&tsym=",ccy[1],"&limit=",frequency,"&aggregate=1&e=Binance\"";
               //`hour~params`cfg;
                    query: "\"https://min-api.cryptocompare.com/data/histohour?fsym=",ccy[0],"&tsym=",ccy[1],"&limit=",frequency,"&aggregate=1\""
            ];
        :(query;`$raze ccy)
    };

getHisto:{[params] 
    ccy:(),params`ccy;
    if[not `frequency in key params;params[`frequency]:30];
    if[not `cfg in key params;params[`cfg]:`day];
    queries:queryBuilder each {[x;params](params _ `ccy),enlist[`ccy]!enlist[x]}[;params] each ccy;
    res:{.tmp.x:x;update sym:x[1] from $[(res:postProcess curl x 0)[`Response] like "*Error*";flip (`time`close`high`low`open`volumefrom`volumeto`sym)!(`float$();`float$();`float$();`float$();`float$();`float$();`float$();`symbol$());res`Data]} each queries;
    `date`time`sym xcols update date:"d"$time,time:"t"$time from update time:timestamptoDT time*1000,average:sum (1 2 2 1) * (low;close;open;high) %6 from (uj) over res
 };


//building Historical Quotes either hours or daily
quote:getHisto params;


//res:select time,sym,close from histo where sym = `NEOBTC;

//`res 0: csv 0: `$":C:\\temp\\kdb\\res.csv"

//(`$":C:\\temp\\kdb\\res.csv") 0: csv 0: res

