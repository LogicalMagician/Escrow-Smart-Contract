pragma solidity >=0.7.0 <0.9.0;

contract Escrow {
    
    address payable public depositor; 
    address payable public recipient;
    uint public amount;
    bool public funded;
    bool public complete;
    bool public canceled;
    uint public cancelTime;
    
    constructor() payable {
        depositor = payable(msg.sender);
        amount = msg.value;
        funded = true;
    }
    
    modifier onlyDepositor() {
        require(msg.sender == depositor, "Only the depositor can call this function.");
        _;
    }
    
    modifier onlyRecipient() {
        require(msg.sender == recipient, "Only the recipient can call this function.");
        _;
    }
    
    modifier isFunded() {
        require(funded == true, "The contract must be funded before this function can be called.");
        _;
    }
    
    modifier isComplete() {
        require(complete == true, "The trade must be marked as complete before this function can be called.");
        _;
    }
    
    modifier notCanceled() {
        require(canceled == false, "The trade has been canceled and can no longer be executed.");
        _;
    }
    
    function assignRecipient(address payable _recipient) public onlyDepositor {
        require(_recipient != address(0), "Recipient address cannot be null.");
        recipient = _recipient;
    }
    
    function markComplete() public onlyDepositor isFunded notCanceled {
        complete = true;
    }
    
    function cancel() public onlyDepositor notCanceled {
        canceled = true;
        cancelTime = block.timestamp;
    }
    
    function acknowledgeFunding() public onlyRecipient isFunded notCanceled {
        funded = false;
    }
    
    function withdraw() public onlyRecipient isFunded isComplete notCanceled {
        recipient.transfer(amount);
    }
    
    function releaseToDepositor() public onlyDepositor isFunded isComplete notCanceled {
        depositor.transfer(amount);
    }
    
    function releaseToRecipient() public onlyRecipient isFunded isComplete notCanceled {
        recipient.transfer(amount);
    }
    
    function refundDepositor() public onlyDepositor notCanceled {
        require(block.timestamp > cancelTime + 7 days, "Depositor cannot refund until 7 days have passed since cancelation.");
        depositor.transfer(amount);
    }
    
}
