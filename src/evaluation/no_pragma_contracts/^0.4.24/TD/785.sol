contract ContentPublishing {
 struct Content {
 string data;
 uint publishTime;
 }
 Content[] public contents;

 function publish(string memory _data) public {
 contents.push(Content(_data, block.timestamp));
 }

 function getRecentContent(uint _threshold) public view returns (string memory) {
 require(contents.length > 0, "No content");
 for (uint i = contents.length - 1; i >= 0; i--) {
 if (block.timestamp - contents[i].publishTime <= _threshold) {
 return contents[i].data;
 }
 }
 return "No recent content";
 }
}