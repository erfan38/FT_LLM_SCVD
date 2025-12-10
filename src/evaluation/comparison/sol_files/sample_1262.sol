pragma solidity ^0.8.0;
function createSeries(
bytes name,
uint shares,
string industry,
string symbol,
address extraContract
) payable returns (
address seriesAddress,
uint seriesId
) {
seriesId = series.length;

var(latestAddress, latestName) = SeriesFactory(seriesFactory).createSeries.value(msg.value)(seriesId, name, shares, industry, symbol, msg.sender, extraContract);
if (latestAddress == 0)
throw;

if (latestName > 0)
if (seriesByName[latestName] == 0)
seriesByName[latestName] = latestAddress;
else
throw;

series.push(latestAddress);
expiresAt[latestAddress] = now + 1 years;
latestSeriesForUser[msg.sender] = latestAddress;
seriesByAddress[latestAddress] = latestName;

SeriesCreated(latestAddress, seriesId);
return (latestAddress, seriesId);
}





function addr(bytes32 _name) constant returns(address o_address) {
return seriesByName[_name];
}