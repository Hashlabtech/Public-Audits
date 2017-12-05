pragma solidity 0.4.15;

contract Ownable {

  address public owner;

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

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
  }

}
contract FiatPrice is Ownable {

  Token token;

  address public sender;

  struct Token {
  uint256 usd;
  uint256 eur;
  }

  // initialize function
  function FiatPrice(address _sender) {
    sender = _sender;
  }

  // returns 0.01 value in United States Dollar
  function USD() constant returns (uint256) {
    return token.usd;
  }

  // returns 0.01 value in Euro
  function EUR() constant returns (uint256) {
    return token.eur;
  }

  // update market rates in USD, EURO, and GBP for a specific coin
  function update(uint256 usd, uint256 eur) external {
    require(msg.sender == sender || msg.sender == owner);
    token = Token(usd, eur);
  }

  // change sender address
  function changeSender(address _sender) onlyOwner {
    sender = _sender;
  }

}
