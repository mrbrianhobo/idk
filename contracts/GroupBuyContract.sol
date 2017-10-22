pragma solidity ^0.4.15;

contract GroupBuyContract {
  
	//
  uint numBuys;
  mapping (uint => GroupBuy) groupBuys;
  mapping (uint => Purchase[]) purchases;
  mapping (uint => mapping (address => Purchase)) groupBuyIDs; 
  
  //current status of a purchase order (Ongoing/Ended group buy)
  enum Status { Ongoing, Ended }

  //purchases from individual users will include their physical address, how much they bought, and their ethereum address
  struct Purchase {
//       	string location;
    		address user;
    		uint numUnits;
    		uint amountPaid;
      }
  
  //each GroupBuy struct represents a distinct purchase order
	struct GroupBuy {
        string name;
        address seller;
        uint startTime;
        uint timeLimit;
        uint unitPrice;
        uint purchaseGoal;
        uint numPurchased;
        uint totalFunding;
        Status status;
        bool funded;
  }
  
  modifier validPurchase(uint _GroupBuyID, uint _numUnits) {
      GroupBuy storage g = groupBuys[_GroupBuyID];
      require(g.status == Status.Ongoing);
      require(msg.value >= g.unitPrice * _numUnits);
      _;
  }
  
  modifier updateStatus(uint _GroupBuyID) {
  	_;
    if (groupBuys[_GroupBuyID].numPurchased >= groupBuys[_GroupBuyID].purchaseGoal) {
    	groupBuys[_GroupBuyID].funded = true;
    }
    if (now >= groupBuys[_GroupBuyID].startTime + groupBuys[_GroupBuyID].timeLimit * 1 days) {
    	groupBuys[_GroupBuyID].status = Status.Ended;
    }
  }
  
  function GroupBuyContract() {
  	numBuys = 0;
  }
  
  function createGroupBuy(string _name, uint _timeLimit, uint _unitPrice, uint _purchaseGoal) {
    numBuys += 1;
  	groupBuys[numBuys] = GroupBuy({
      name: _name,
      seller: msg.sender,
      startTime: now,
      timeLimit: _timeLimit,
      unitPrice: _unitPrice,
      purchaseGoal: _purchaseGoal,
      numPurchased: 0,
      totalFunding: 0,
      status: Status.Ongoing,
      funded: false
    });
  }
  
  function purchase(uint _GroupBuyID, uint _numUnits) payable updateStatus(_GroupBuyID) validPurchase(_GroupBuyID,_numUnits) {
    GroupBuy storage g = groupBuys[_GroupBuyID];
    uint refund = msg.value - g.unitPrice * _numUnits;
    Purchase memory p = Purchase({
      user: msg.sender,
      numUnits: _numUnits,
      amountPaid: g.unitPrice * _numUnits
    });
    g.numPurchased += _numUnits;
    g.totalFunding += g.unitPrice * _numUnits;
    groupBuyIDs[_GroupBuyID][msg.sender] = p;
    purchases[_GroupBuyID].push(p);
    msg.sender.transfer(refund);
  }
  
  
  function getGroupBuy(uint _GroupBuyID) returns (string, address, uint, uint, uint, uint, uint, uint, string, bool) {
      GroupBuy storage g = groupBuys[_GroupBuyID];
      if (g.status == Status.Ongoing) {
          return (g.name, 
              g.seller, 
              g.startTime, 
              g.timeLimit, 
              g.unitPrice,
              g.purchaseGoal,
              g.numPurchased,
              g.totalFunding,
              "ongoing",
              g.funded);
      } else {
          return (g.name, 
                  g.seller, 
                  g.startTime, 
                  g.timeLimit, 
                  g.unitPrice,
                  g.purchaseGoal,
                  g.numPurchased,
                  g.totalFunding,
                  "ended",
                  g.funded);
      }
  }

  function getTotalGroupBuys() returns (uint) { return numBuys; }
  
  function getMyBalance() returns (uint) { return this.balance; }
  
  function() public payable {
    
  }
}
