
/* Add by mengmeng.zhang */

/* Update SQL */

/* touch "`ruby -e "puts Time.now.strftime('%Y%m%d%H%M%S%3N').to_i"`"_CreateMyAwesomeTable.sql   生成该文件的命令 */



/* Nudges记录 */

CREATE TABLE IF NOT EXISTS T_DB_Nudges(
contactId text,
campaignId integer,
flowId integer,
processId text,
campaignExpDate text,
nudgesId integer,
nudgesName text,
remainTimes integer,
height integer,
width integer,
adviceCode text,
channelCode text,
nudgesType text,
pageName text,
findIndex text,
ownProp text,
position text,
appExtInfo text,
background text,
border text,
backdrop text,
dismiss text,
title text,
body text,
image text,
video text,
buttons text,
dismissButton text,
isShow integer
);



/* 频次记录 */

CREATE TABLE IF NOT EXISTS T_DB_Frequency(
repeatInterval integer,
sessionTimes integer,
hourTimes integer,
dayTimes integer,
weekTimes integer,
lastTime text
);


