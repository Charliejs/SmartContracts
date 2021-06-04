pragma solidity 0.8.4;
pragma abicoder v2;
//["0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db","0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB","0x17F6AD8Ef982297579C203069C1DbfFE4348c372"]
//0x0A098Eda01Ce92ff4A4CCb7A4fFFb5A43EBC70DC
contract Wallet{
    address[] public owners;
    uint limit;
    struct Transfer{
        uint amount;
        address payable reciever;
        uint approvals;
        bool hasBeenSent;
        uint id;
    }
    event TransferRequestsCreated(uint _id, uint _amount, address _initiator, address _reciever);
    event ApprovalRecieved(uint _id, uint _approvals, address _approver);
    event TransferApproved(uint _id);
    Transfer[] transferRequests;
    mapping(address => mapping(uint=>bool)) approvals;
    modifier onlyOwners(){
        bool owner = false;
        for(uint i=0; i<owners.length;i++){
            if(owners[i] == msg.sender){
                owner = true;
            }
        }
        require(owner == true);
        _;
    }
    constructor (address[] memory _owners, uint _limit){
        owners = _owners;
        limit = _limit;
    }
    function deposit()public payable{}
    function createTransfer(uint _amount, address payable _reciever) public onlyOwners{
            emit TransferRequestsCreated(transferRequests.length, _amount, msg.sender, _reciever);
            transferRequests.push(
                Transfer(_amount, _reciever, 0, false, transferRequests.length)
                );
    }    
    function approve(uint _id) public onlyOwners{
        require(approvals[msg.sender][_id] == false);
        require(transferRequests[_id].hasBeenSent == false);
        approvals[msg.sender][_id] = true;
        transferRequests[_id].approvals++;
        emit ApprovalRecieved(_id, transferRequests[_id].approvals, msg.sender);
        if(transferRequests[_id].approvals >= limit){
            transferRequests[_id].hasBeenSent = true;
            transferRequests[_id].reciever.transfer(transferRequests[_id].amount);
            emit TransferApproved(_id);
        }
    }
    function getTransferRequest()public view returns (Transfer[]memory){
        return transferRequests;
    }
    function getBalance() public view returns (uint){
        return address(this).balance;
    }
}