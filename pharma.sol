pragma solidity ^0.4.4;

contract pharma {

   address public creatorAdmin;
	 enum Status { NotExist, Pending, Approved, Rejected }
	 enum QuotStatus {NotExist, Quoted, QuoteApproved, QuoteRejected, ReQuoted }
   enum Rawmat { Sulphur, Phosphorous, Iron, Calcium }


  struct Mfg {
    uint mfgid;
    string mfgname;
    string productname;

    uint[] mfgquotlist;

 		Status status;
 		address mfgaddress;
    address createdby;
 		uint createdat;
 	}

  struct Sup {
    uint supid;
    string supname;

    Rawmat[] rawmat;
    uint[] price;

    uint[] supquotlist;

    Status status;
    address supaddress;
    address createdby;
    uint createdat;
  }

  struct Quot {
    Rawmat rawmat;
    uint quantity;
    uint price;
    QuotStatus status;
    uint supid;
    uint mfgid;
    uint createdat;
  }

  struct Admin {
		string name;
    Status status;
    address adminaddress;
		address createdby;
		uint createdat;
	}


	mapping(uint => Mfg) public Mfgs;
  mapping(uint => Sup) public Sups;
  mapping(address => uint) public Mfgsid;
  mapping(address => uint) public Supsid;
  uint Quotlist;
  mapping(uint => Quot) public Quots;
	mapping(address => Admin) public Admins;



	modifier verifiedAdmin() {
		require(users[msg.sender] >= 2 && verifiedUsers[msg.sender]);
		_;
	}
  modifier onlySuperAdmins() {
		require(msg.sender == creatorAdmin);
		_;
	}


	function pharma() {
		creatorAdmin = msg.sender;
    Admins[msg.sender] = Admin("SuperAdmin", Status.Approved, msg.sender, now);
	}




  function createmfg(uint _mfgid, string _mfgname, string _productname, address _mfgaddress) verifiedAdmin returns (bool) {
	require(Mfgs[_mfgid].status == Status.NotExist);
  Mfgs[_mfgid] = Mfg({mfgid: _mfgid, mfgname: _mfgname, productname:_productname, status:Status.Pending, mfgaddress:_mfgaddress, createdby:msg.sender, createdat:now });
  Mfgsid[_mfgaddress] = _mfgid;
  }

  function createsup(uint _supid, string _supname, uint[] _rawmat, uint[] _price, address _supaddress) verifiedAdmin returns (bool) {
  require(Sups[_supid].status == Status.NotExist);
  Sups[_supid] = Sup({supid: _supid, supname: _supname, rawmat: _rawmat, price:_price, status:Status.Pending, supaddress:_supaddress, createdby:msg.sender, createdat:now });
  Supsid[_supaddress] = _supid;
  }

  function createadmin(string _name, address _adminaddress) verifiedAdmin returns (bool) {
  require(Admins[_adminaddress].status == Status.NotExist);
  Admins[_adminaddress] = Admin(_name, Status.Pending, _adminaddress, msg.sender, now);
  }

  function approvemfg(uint _id) verifiedAdmin returns (bool) {
  require(Mfgs[_id].createdby != msg.sender || creatorAdmin == msg.sender);
  require(Mfgs[_id].status == Status.Pending);
  Mfgs[_id].status = Status.Approved;
  }
  function rejectmfg(uint _id) verifiedAdmin returns (bool) {
  require(Mfgs[_id].createdby != msg.sender || creatorAdmin == msg.sender);
  require(Mfgs[_id].status == Status.Pending);
  Mfgs[_id].status = Status.Rejected;
  }

  function approvesup(uint _id) verifiedAdmin returns (bool) {
  require(Sups[_id].createdby != msg.sender || creatorAdmin == msg.sender);
  require(Sups[_id].status == Status.Pending);
  Sups[_id].status = Status.Approved;
  }
  function rejectsup(uint _id) verifiedAdmin returns (bool) {
  require(Sups[_id].createdby != msg.sender || creatorAdmin == msg.sender);
  require(Sups[_id].status == Status.Pending);
  Sups[_id].status = Status.Rejected;
  }

  function approveadmin(address _adminaddress) onlySuperAdmins returns (bool) {
  require(Admins[_adminaddress].status == Status.Pending);
  Admins[_adminaddress].status = Status.Approved;
  }
  function rejectadmin(address _adminaddress) onlySuperAdmins returns (bool) {
  require(Admins[_adminaddress].status == Status.Pending);
  Admins[_adminaddress].status = Status.Rejected;
  }

  function searchsup(uint _supid) constant returns (uint, string, uint[], uint[], Status) {
  Sup storage sup = Sups[_supid];
  return (sup.supid, sup.supname, sup.rawmat, sup.price, sup.productname, sup.status);
  }
  function searchmfg(uint _mfgid) constant returns (uint, string, string, Status) {
  Mfg storage mfg = Mfgs[_mfgid];
  return (mfg.mfgid, mfg.mfgname, mfg.productname, mfg.status);
  }

  function createquot(uint _mfgid, Rawmat _rawmat, uint _quantity, uint _price, uint _supid) returns (bool) {
  require(Mfgs[_mfgid].mfgaddress == msg.sender);
  require(Mfgs[_mfgid].status == Status.Approved);
  require(Sups[_supid].status == Status.Approved);
  Quotlist++;
  Quots[Quotlist] = Quot(_rawmat, _quantity, _price, QuotStatus.Quoted, _supid, _mfgid, now );
  Mfgs[_mfgid].mfgquotlist.push(Quotlist);
  Sups[_supid].supquotlist.push(Quotlist);
  }

  function requot(uint _quotlist, uint _quantity, uint _price) returns (bool) {
  require(Quots[_quotlist].status == QuotStatus.Quoted);
  require(Quots[_quotlist].supid == Supsid[msg.sender]);
  Quots[_quotlist].quantity = _quantity;
  Quots[_quotlist].price = _price;
  Quots[_quotlist].status = QuotStatus.ReQuoted;
  }

  function approvequot(uint _quotlist) returns (bool) {
  require(Quots[_quotlist].status == QuotStatus.Quoted);
  require(Quots[_quotlist].supid == Supsid[msg.sender]);
  Quots[_quotlist].status = QuotStatus.Approved;
  }

  function rejectquot(uint _quotlist) returns (bool) {
  require(Quots[_quotlist].status == QuotStatus.Quoted);
  require(Quots[_quotlist].supid == Supsid[msg.sender]);
  Quots[_quotlist].status = QuotStatus.Rejected;
  }

  function approverequot(uint _quotlist) returns (bool) {
  require(Quots[_quotlist].status == QuotStatus.ReQuoted);
  require(Quots[_quotlist].mfgid == Mfgsid[msg.sender]);
  Quots[_quotlist].status = QuotStatus.Quoted;
  }

  function rejectrequot(uint _quotlist) returns (bool) {
  require(Quots[_quotlist].status == QuotStatus.ReQuoted);
  require(Quots[_quotlist].mfgid == Mfgsid[msg.sender]);
  Quots[_quotlist].status = QuotStatus.Rejected;
  }

  function mfgquotlist(uint _id) returns (bool){
  require(Mfgs[_id].status == Status.Approved);
  Mfg storage mfg = Mfgs[_id];
  return (mfg.mfgquotlist);

  }
  function supquotlist(uint _id) returns (bool){
  require(Sups[_id].status == Status.Approved);
  Sup storage sup = Sups[_id];
  return (sup.mfgquotlist);
  }
  function getquot(uint _quotid) returns(Rawmat, uint, uint, QuotStatus, uint, uint, uint){
  require(Quots[_quotid].createdat != 0);
  Quot storage quot = Quots[_quotid];
  return(quot.rawmat, quot.quantity, quot.price, quot.status, quot.supid, quot.mfgid, quot.createdat);
}



}
