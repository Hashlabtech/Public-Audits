pragma solidity ^0.4.15;


contract Ownable {

  address public owner;
  address public manager;

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  modifier onlyManagerOrOwner() {
    require(msg.sender == owner || msg.sender == manager);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
  }

}

library SafeMath {

  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


contract Stateful {
  enum State {
  Free,
  Voting
  }
  State public state = State.Free;

  event StateChanged(State oldState, State newState);

  function setState(State newState) internal {
    State oldState = state;
    state = newState;
    StateChanged(oldState, newState);
  }
}


contract ICOEscrow is Ownable, Stateful, SafeMath {

  struct Request{
    uint256 amount;
    address reciever;
  }

  Request public request;

  modifier onlyAtVoting() {

  }

  function approveRequest() onlyAtVoting {

  }

  function declineRequest() onlyAtVoting {

  }

  function requestEther(address _reciever, uint256 _amount) onlyManagerOrOwner {
    request.amount = _amount;
    request.reciever = _reciever;
    setState(State.Voting);
  }

  function getEther() onlyCrowdsaleManagerOrOwner {

  }

  function () payable {}


}
